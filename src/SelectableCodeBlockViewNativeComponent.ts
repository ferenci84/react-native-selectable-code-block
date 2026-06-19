import { codegenNativeComponent, type ViewProps } from 'react-native';
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

export default codegenNativeComponent<NativeProps>('SelectableCodeBlockView');