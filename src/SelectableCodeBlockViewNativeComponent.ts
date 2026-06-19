import { codegenNativeComponent, type ViewProps } from 'react-native';
import type {
  DirectEventHandler,
  Float,
} from 'react-native/Libraries/Types/CodegenTypesNamespace';

export interface SelectionEvent {
  chosenOption: string;
  highlightedText: string;
}

interface NativeProps extends ViewProps {
  tokensJson: string;
  fontFamily?: string;
  fontSize?: Float;
  lineHeight?: Float;
  color?: string;
  selectable?: boolean;
  menuOptions: readonly string[];
  onSelection?: DirectEventHandler<SelectionEvent>;
}

export default codegenNativeComponent<NativeProps>('SelectableCodeBlockView');