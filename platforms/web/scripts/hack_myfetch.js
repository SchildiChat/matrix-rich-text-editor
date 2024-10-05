/*
Copyright 2024 New Vector Ltd.
Copyright 2022 The Matrix.org Foundation C.I.C.

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
*/

/*
 * The base64 utils here are taken from:
 * https://developer.mozilla.org/en-US/docs/Glossary/Base64
 * (Code samples from MDN are released under CC0.)
 */

/*
 * Modify our generated code to replace the use of the fetch function with a
 * custom implementation that does not actually call fetch, because that
 * can fall foul of a Content Security Policy.
 *
 * Our replacement will only work with a data: URL, but fortunately that is
 * what we are using here.
 *
 * It simply interprets the data: URL and creates a Response object without
 * actually fetching anything.
 */

import replace from 'replace';

console.log('[hack_myfetch] Hacking generated files to avoid using fetch()');

const code = `(function(){
    function myfetch(dataurl) {
        const cruftLength = 'data:application/wasm;base64,'.length;
        let body = dataurl.toString();
        body = body.substring(cruftLength);
        const response = new Response(base64DecToArr(body));
        return response;
    }

    function b64ToUint6(nChr) {
        return nChr > 64 && nChr < 91
            ? nChr - 65
            : nChr > 96 && nChr < 123
            ? nChr - 71
            : nChr > 47 && nChr < 58
            ? nChr + 4
            : nChr === 43
            ? 62
            : nChr === 47
            ? 63
            : 0;
    }

    function base64DecToArr(sBase64, nBlocksSize) {
        const sB64Enc = sBase64.replace(/[^A-Za-z0-9+/]/g, "");
        const nInLen = sB64Enc.length;
        const nOutLen = nBlocksSize
            ? Math.ceil(((nInLen * 3 + 1) >> 2) / nBlocksSize) * nBlocksSize
            : (nInLen * 3 + 1) >> 2;
        const taBytes = new Uint8Array(nOutLen);

        let nMod3;
        let nMod4;
        let nUint24 = 0;
        let nOutIdx = 0;
        for (let nInIdx = 0; nInIdx < nInLen; nInIdx++) {
            nMod4 = nInIdx & 3;
            nUint24 |= (
                b64ToUint6(sB64Enc.charCodeAt(nInIdx)) <<
                (6 * (3 - nMod4))
            );
            if (nMod4 === 3 || nInLen - nInIdx === 1) {
                nMod3 = 0;
                while (nMod3 < 3 && nOutIdx < nOutLen) {
                    taBytes[nOutIdx] = (
                        nUint24 >>> ((16 >>> nMod3) & 24)
                    ) & 255;
                    nMod3++;
                    nOutIdx++;
                }
                nUint24 = 0;
            }
        }

        return taBytes;
    }

    return myfetch($1)
}())`;

// Note: we do very simple search+replace here, so if the code contains other
// fetch calls, they will be messed up.

replace({
    regex: /fetch\((\w+)\)/,
    replacement: code.replace(/\n\s*/g, ''),
    paths: ['./dist/matrix-wysiwyg.umd.cjs', './dist/matrix-wysiwyg.js'],
    recursive: false,
    silent: false,
});
