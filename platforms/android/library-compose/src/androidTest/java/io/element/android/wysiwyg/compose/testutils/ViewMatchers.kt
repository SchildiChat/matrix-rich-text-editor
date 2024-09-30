/*
 * Copyright 2024 New Vector Ltd.
 * Copyright 2024 The Matrix.org Foundation C.I.C.
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 * Please see LICENSE in the repository root for full details.
 */

package io.element.android.wysiwyg.compose.testutils

import android.view.View
import androidx.test.espresso.matcher.ViewMatchers
import io.element.android.wysiwyg.EditorEditText
import org.hamcrest.Matcher

object ViewMatchers {
    fun isRichTextEditor(): Matcher<View> =
        ViewMatchers.isAssignableFrom(EditorEditText::class.java)
}