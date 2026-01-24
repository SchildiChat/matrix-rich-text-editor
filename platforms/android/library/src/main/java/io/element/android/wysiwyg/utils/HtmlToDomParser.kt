package io.element.android.wysiwyg.utils

import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import org.jsoup.nodes.Document.OutputSettings
import org.jsoup.safety.Safelist

object HtmlToDomParser {
    fun document(html: String): Document {
        val outputSettings = OutputSettings().prettyPrint(false).indentAmount(0)
        val cleanHtml = Jsoup.clean(html, "", safeList, outputSettings)
        return Jsoup.parse(cleanHtml)
    }

    private val safeList = Safelist()
        .addTags(
            "a", "b", "strong", "i", "em", "u", "del", "code", "ul", "ol", "li", "pre",
            "blockquote", "p", "br", "img"
        )
        .addAttributes("a", "href", "data-mention-type", "contenteditable")
        .addAttributes("img", "src", "title", "alt", "width", "height", "data-mx-emoticon")
        .addAttributes("ol", "start")
}
