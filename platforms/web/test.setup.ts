/*
Copyright 2024 New Vector Ltd.
Copyright 2022 The Matrix.org Foundation C.I.C.

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
*/

// We are using node api here
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck

import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import fs from 'node:fs/promises';
import path from 'path';

globalThis.fetch = (url): Promise<Buffer> => {
    // wysiwyg.js binding uses fetch to get the wasm file
    // we return manually here the wasm file
    if (url instanceof URL && url.href.includes('wysiwyg_bg.wasm')) {
        const wasmPath = path.resolve(__dirname, 'generated/wysiwyg_bg.wasm');
        return fs.readFile(wasmPath);
    } else {
        throw new Error('fetch is not defined');
    }
};

// Work around missing ClipboardEvent type
class MyClipboardEvent {}
globalThis.ClipboardEvent = MyClipboardEvent as ClipboardEvent;

afterEach(() => {
    cleanup();
});
