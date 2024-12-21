/*
 * Copyright 2024 New Vector Ltd.
 * Copyright 2024 The Matrix.org Foundation C.I.C.
 * Copyright 2024 SpiritCroc
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 * Please see LICENSE in the repository root for full details.
 */

package io.element.android.wysiwyg.view.spans

import android.graphics.Canvas
import android.graphics.Paint
import android.text.style.ReplacementSpan
import kotlin.math.roundToInt

class InlineImageSpan(
    val src: String,
    val isEmoticon: Boolean = false,
    val title: String? = null,
    val alt: String? = null,
    val width: Int? = null,
    val height: Int? = null,
) : ReplacementSpan() {

    val fallbackText: String?
        get() = alt ?: title

    override fun getSize(
        paint: Paint,
        text: CharSequence?,
        start: Int,
        end: Int,
        fm: Paint.FontMetricsInt?
    ): Int {
        return paint.measureText(text ?: fallbackText, start, end).roundToInt()
    }

    override fun draw(
        canvas: Canvas,
        text: CharSequence?,
        start: Int,
        end: Int,
        x: Float,
        top: Int,
        y: Int,
        bottom: Int,
        paint: Paint
    ) {
        canvas.drawText(text ?: fallbackText ?: "IMG", start, end, x, y.toFloat(), paint)
    }
}
