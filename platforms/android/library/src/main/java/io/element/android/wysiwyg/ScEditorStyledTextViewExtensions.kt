package io.element.android.wysiwyg

import android.text.Spanned
import io.element.android.wysiwyg.view.spans.CodeBlockSpan

fun CharSequence.allowWrapWidth(): Boolean {
    if (this is Spanned) {
        return getSpans(0, length, CodeBlockSpan::class.java).isEmpty()
    }
    return true
}
