import { type ViewProps } from 'react-native';
import type { DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypesNamespace';
export interface SelectionEvent {
    chosenOption: string;
    highlightedText: string;
}
interface NativeProps extends ViewProps {
    tokensJson: string;
    fontFamily?: string;
    fontSize?: number;
    lineHeight?: number;
    color?: string;
    selectable?: boolean;
    menuOptions: readonly string[];
    onSelection?: DirectEventHandler<SelectionEvent>;
}
declare const _default: import("react-native/types_generated/Libraries/Utilities/codegenNativeComponent").NativeComponentType<NativeProps>;
export default _default;