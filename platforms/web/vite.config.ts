/*
Copyright 2024 New Vector Ltd.
Copyright 2022 The Matrix.org Foundation C.I.C.

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
*/

import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';
import dts from 'vite-plugin-dts';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        react(),
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        dts({
            include: [
                'lib/useWysiwyg.ts',
                'lib/conversion.ts',
                'lib/types.ts',
                'lib/constants.ts',
                'lib/useListeners/types.ts',
                'lib/useTestCases/types.ts',
            ],
            rollupTypes: true,
        }),
    ],
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: 'test.setup.ts',
        includeSource: ['lib/**/*.{ts,tsx}'],
        coverage: {
            all: true,
            include: ['lib/**/*.{ts,tsx}'],
            exclude: [
                'lib/testUtils/**/*.{ts,tsx}',
                'lib/**/*test.{ts,tsx}',
                'lib/**/*.d.ts',
                'lib/**/types.ts',
            ],
            reporter: ['text', 'lcov'],
        },
        reporters: ['default', 'vitest-sonar-reporter'],
        outputFile: 'coverage/sonar-report.xml',
        onConsoleLog: (log) => {
            if (log.includes('wasm')) return false;
        },
    },
    build: {
        lib: {
            entry: resolve(__dirname, 'lib/useWysiwyg.ts'),
            name: 'Matrix wysiwyg',
            // the proper extensions will be added
            fileName: 'matrix-wysiwyg',
        },
        rollupOptions: {
            // make sure to externalize deps that shouldn't be bundled
            // into your library
            external: ['react', 'react-dom'],
            output: {
                // Provide global variables to use in the UMD build
                // for externalized deps
                globals: {
                    'react': 'React',
                    'react-dom': 'ReactDOM',
                },
            },
        },
    },
});
