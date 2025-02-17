//
// Copyright 2024 New Vector Ltd.
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE in the repository root for full details.
//

import Foundation

/// Describe an eror occuring during HTML to attributed ranges manipulation.
public enum AttributedRangeError: LocalizedError, Equatable {
    /// Index is out of expected HTML bounds.
    case outOfBoundsHtmlIndex(index: Int)
    /// Index is out of attributed bounds.
    case outOfBoundsAttributedIndex(index: Int)

    public var errorDescription: String? {
        switch self {
        case let .outOfBoundsHtmlIndex(index: index):
            return "Provided HTML index is out of expected bounds (\(index))"
        case let .outOfBoundsAttributedIndex(index: index):
            return "Provided attributed index is out of bounds (\(index))"
        }
    }
}

extension NSAttributedString {
    // MARK: - Public

    /// Computes range inside the HTML raw text from the
    /// range inside the attributed representation.
    ///
    /// - Parameters:
    ///   - attributedRange: the range inside the attributed representation
    /// - Returns: the range inside the HTML raw text
    public func htmlRange(from attributedRange: NSRange) throws -> NSRange {
        let start = try htmlPosition(at: attributedRange.location)
        let end = try htmlPosition(at: attributedRange.upperBound)
        return NSRange(location: start, length: end - start)
    }

    /// Computes a range inside the attributed representation from
    /// the range inside the HTML raw text.
    ///
    /// - Parameters:
    ///   - htmlRange: the range inside the HTML raw text
    /// - Returns: the range inside the attributed representation
    public func attributedRange(from htmlRange: NSRange) throws -> NSRange {
        let start = try attributedPosition(at: htmlRange.location)
        let end = try attributedPosition(at: htmlRange.upperBound)
        return NSRange(location: start, length: end - start)
    }

    /// Computes a string with all characters of the `NSAttributedString` that are actually part of the HTML.
    /// Positions in this string will return a range that conforms to the range returned by the Rust model.
    public var htmlChars: String {
        NSMutableAttributedString(attributedString: self)
            .removeDiscardableContent()
            .addPlaceholderForReplacements()
            .string
    }

    // MARK: - Internal

    /// Compute an array of all detected occurences of discardable
    /// text (list prefixes, placeholder characters) within the given range
    /// of the attributed text.
    ///
    /// - Parameters:
    ///   - range: the range on which the elements should be detected. Entire range if omitted
    /// - Returns: an array of matching ranges
    func discardableTextRanges(in range: NSRange? = nil) -> [NSRange] {
        // When typing a space into an empty composer, the single space being disposable results in
        // `applyReplaceAll` failing, leaving attributedContent out of sync. The reconciliation then
        // adds a second space to the model that isn't in the text view.
        if string == .zwsp {
            // This fixes that, although it doesn't help in the case of adding a single space to e.g.
            // a list/quote where the same result can be seen with the model having an extra space.
            return []
        }
        
        var ranges = [NSRange]()

        enumerateTypedAttribute(.discardableText, in: range) { (isDiscardable: Bool, range: NSRange, _) in
            if isDiscardable {
                ranges.append(range)
            }
        }

        return ranges
    }

    /// Compute an array of all parts of the attributed string that have been replaced
    /// with `MentionReplacer` usage within the given range.
    ///
    /// - Parameter range: the range on which the elements should be detected. Entire range if omitted
    /// - Returns: an array of `Replacement`.
    func mentionReplacementTextRanges(in range: NSRange? = nil) -> [MentionReplacement] {
        var replacements = [MentionReplacement]()

        enumerateTypedAttribute(.mention) { (mentionContent: MentionContent, range: NSRange, _) in
            replacements.append(MentionReplacement(range: range, content: mentionContent))
        }

        return replacements
    }

    /// Compute an array of all parts of the attributed string that have been replaced
    /// with `MentionReplacer` usage up to the provided index.
    ///
    /// - Parameter attributedIndex: the position until which the ranges should be computed.
    /// - Returns: an array of range and offsets.
    func mentionReplacementTextRanges(to attributedIndex: Int) -> [MentionReplacement] {
        mentionReplacementTextRanges(in: .init(location: 0, length: attributedIndex))
    }

    /// Find occurences of parts of the attributed string that have been replaced
    /// within the range before given attributed index and compute the total offset
    /// that should be subtracted (HTML to attributed) or added (attributed to HTML)
    /// in order to compute the index properly.
    ///
    /// - Parameter attributedIndex: the index inside the attributed representation
    /// - Returns: Total offset of replacement ranges
    func replacementsOffsetAt(at attributedIndex: Int) -> Int {
        mentionReplacementTextRanges(to: attributedIndex)
            .map { $0.range.upperBound <= attributedIndex
                ? $0.offset
                : attributedIndex > $0.range.location
                ? attributedIndex - $0.range.location - $0.content.rustLength
                : 0
            }
            .reduce(0, -)
    }

    /// Computes index inside the HTML raw text from the index
    /// inside the attributed representation.
    ///
    /// - Parameters:
    ///   - attributedIndex: the index inside the attributed representation
    /// - Returns: the index inside the HTML raw text
    func htmlPosition(at attributedIndex: Int) throws -> Int {
        guard attributedIndex <= length else {
            throw AttributedRangeError
                .outOfBoundsAttributedIndex(index: attributedIndex)
        }

        let replacementsOffset = replacementsOffsetAt(at: attributedIndex)
        return discardableTextRanges(in: .init(location: 0, length: attributedIndex))
            // All ranges length should be counted out, unless the last one end strictly after the
            // attributed index, in that case we only count out the difference (i.e. chars before the index)
            .map { $0.upperBound <= attributedIndex ? $0.length : attributedIndex - $0.location }
            .reduce(attributedIndex, -) + replacementsOffset
    }

    /// Computes index inside the attributed representation from the index
    /// inside the HTML raw text.
    ///
    /// - Parameters:
    ///   - htmlIndex: the index inside the HTML raw text
    /// - Returns: the index inside the attributed representation
    func attributedPosition(at htmlIndex: Int) throws -> Int {
        var attributedIndex = try discardableTextRanges()
            // All ranges that have a HTML position before the provided index should be entirely counted.
            .compactMap { try htmlPosition(at: $0.location) <= htmlIndex ? Optional($0.length) : nil }
            .reduce(htmlIndex, +)

        // Iterate replacement ranges in order and only account those
        // that are still in range after previous offset update.
        attributedIndex = mentionReplacementTextRanges(to: attributedIndex)
            .reduce(attributedIndex) { $1.range.location < $0 ? $0 + $1.offset : $0 }

        guard attributedIndex <= length else {
            throw AttributedRangeError
                .outOfBoundsHtmlIndex(index: htmlIndex)
        }

        return attributedIndex
    }
}

extension NSMutableAttributedString {
    /// Remove all discardable elements from the attributed
    /// string (i.e. list prefixes, zwsp placeholders, etc)
    ///
    /// - Returns: self (discardable)
    @discardableResult
    func removeDiscardableContent() -> Self {
        for discardableTextRange in discardableTextRanges().reversed() {
            replaceCharacters(in: discardableTextRange, with: "")
        }

        return self
    }

    /// Replace`Replacement` within the attributed string
    /// by placeholders which have the expected Rust model length.
    ///
    /// - Returns: self (discardable)
    @discardableResult
    func addPlaceholderForReplacements() -> Self {
        mentionReplacementTextRanges()
            .filter { $0.range.length != $0.content.rustLength }
            .reversed()
            .forEach {
                replaceCharacters(in: $0.range,
                                  with: String(repeating: Character.object,
                                               count: $0.content.rustLength))
            }

        return self
    }
}
