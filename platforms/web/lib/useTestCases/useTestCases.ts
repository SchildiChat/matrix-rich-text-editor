/*
Copyright 2022 The Matrix.org Foundation C.I.C.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import { RefObject, useCallback, useMemo, useRef, useState } from 'react';

import { ComposerModel } from '../../generated/wysiwyg';
import { Actions } from './types';
import {
    getSelectionAccordingToActions,
    resetTestCase,
    traceAction,
} from './utils';
import { TraceAction } from '../types';

export type UseTestCases = {
    testRef: RefObject<HTMLDivElement>;
    utilities: {
        traceAction: TraceAction;
        getSelectionAccordingToActions: () => [number, number];
        onResetTestCase: () => void | null;
        setEditorHtml: (content: string) => void;
    };
};

export function useTestCases(
    editorRef: RefObject<HTMLElement | null>,
    composerModel: ComposerModel | null,
): UseTestCases {
    const testRef = useRef<HTMLDivElement>(null);
    const [actions, setActions] = useState<Actions>([]);

    const [editorHtml, setEditorHtml] = useState<string>('');

    const setEditor = useCallback(
        (content: string) => {
            if (testRef.current) {
                setEditorHtml(content);
            }
        },
        [testRef],
    );

    const memorizedTraceAction = useMemo(
        () => traceAction(testRef.current, actions, composerModel),
        [testRef, actions, composerModel],
    );

    const memorizedGetSelection = useMemo(
        () => getSelectionAccordingToActions(actions),
        [actions],
    );

    const onResetTestCase = useCallback(
        () =>
            editorRef.current &&
            testRef.current &&
            composerModel &&
            setActions(
                resetTestCase(
                    editorRef.current,
                    testRef.current,
                    composerModel,
                    editorHtml,
                ),
            ),
        [editorRef, testRef, composerModel, editorHtml],
    );

    const utilities = useMemo(
        () => ({
            traceAction: memorizedTraceAction,
            getSelectionAccordingToActions: memorizedGetSelection,
            onResetTestCase,
            setEditorHtml: setEditor,
        }),
        [
            memorizedTraceAction,
            memorizedGetSelection,
            onResetTestCase,
            setEditor,
        ],
    );

    return {
        testRef,
        utilities,
    };
}
