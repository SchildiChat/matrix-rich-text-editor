/*
 * https://stackoverflow.com/questions/7439748/why-is-wrap-content-in-multiple-line-textview-filling-parent
 */

package io.element.android.wysiwyg

import android.content.Context
import android.text.Layout
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView
import timber.log.Timber
import kotlin.math.ceil
import kotlin.math.max

open class WrapWidthTextView @JvmOverloads constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0
) : AppCompatTextView(context, attrs, defStyleAttr) {

    var enableWrapWidth: Boolean = true

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (!enableWrapWidth) return
        val layout = this.layout ?: return
        val width = ceil(getMaxLineWidth(layout)).toInt() + compoundPaddingLeft + compoundPaddingRight
        if (width > measuredWidth) {
            Timber.tag("WrapWidthTextView").w("Calculated width increased, ignore")
            return
        }
        val height = measuredHeight
        setMeasuredDimension(width, height)
    }

    private fun getMaxLineWidth(layout: Layout): Float {
        var maxWidth = 0.0f
        val lines = layout.lineCount
        for (i in 0 until lines) {
            maxWidth = max(maxWidth, layout.getLineWidth(i))
        }
        return maxWidth
    }
}
