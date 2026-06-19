import React from 'react';
import type { ViewStyle } from 'react-native';
import { type SelectionEvent } from './SelectableCodeBlockViewNativeComponent';
export type SelectableCodeToken = {
    text: string;
    color?: string;
    backgroundColor?: string;
    fontWeight?: string;
    fontStyle?: string;
    textDecorationLine?: string;
};
export interface SelectableCodeBlockViewProps {
    tokens: readonly SelectableCodeToken[];
    fontFamily?: string;
    fontSize?: number;
    lineHeight?: number;
    color?: string;
    selectable?: boolean;
    menuOptions?: readonly string[];
    onSelection?: (event: SelectionEvent) => void;
    style?: ViewStyle;
    testID?: string;
}
export declare const SelectableCodeBlockView: React.FC<SelectableCodeBlockViewProps>;