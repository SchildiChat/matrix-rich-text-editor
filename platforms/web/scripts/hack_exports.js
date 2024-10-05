/*
Copyright 2024 New Vector Ltd.
Copyright 2022 The Matrix.org Foundation C.I.C.

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
*/

import replace from 'replace';

console.log('[hack_exports] Hacking generated types to make all exported');

replace({
    regex: /^declare/gm,
    replacement: 'export declare',
    paths: ['./dist/index.d.ts'],
    recursive: false,
    silent: false,
});
