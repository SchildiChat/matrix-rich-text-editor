/*
 * Copyright 2024 New Vector Ltd.
 * Copyright 2024 The Matrix.org Foundation C.I.C.
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 * Please see LICENSE in the repository root for full details.
 */

package io.element.android.wysiwyg.utils

/**
 * HTML converter that is not depend on Android, for unit tests.
 */
class BasicHtmlConverter: HtmlConverter {

    override fun fromHtmlToSpans(html: String): CharSequence = html.replace("<[^>]*>".toRegex(), "")
}