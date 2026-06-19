import React, { useCallback, useEffect, useMemo, useRef } from 'react';
import { DeviceEventEmitter, findNodeHandle, Platform, type ViewStyle } from 'react-native';
import SelectableCodeBlockViewNativeComponent, {
  type SelectionEvent,
} from './SelectableCodeBlockViewNativeComponent';

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
  wrapLines?: boolean;
  menuOptions?: readonly string[];
  onSelection?: (event: SelectionEvent) => void;
  style?: ViewStyle;
  testID?: string;
}

export const SelectableCodeBlockView: React.FC<SelectableCodeBlockViewProps> = ({
  tokens,
  fontFamily,
  fontSize,
  lineHeight,
  color,
  selectable = true,
  wrapLines = false,
  menuOptions = ['Copy'],
  onSelection,
  style,
  testID,
}) => {
  const nativeRef = useRef(null);
  const tokensJson = useMemo(() => JSON.stringify(tokens), [tokens]);

  useEffect(() => {
    if (Platform.OS !== 'android' || !onSelection) {
      return undefined;
    }

    const subscription = DeviceEventEmitter.addListener(
      'SelectableCodeBlockSelection',
      (eventData: SelectionEvent & { viewTag: number }) => {
        const viewTag = findNodeHandle(nativeRef.current);
        if (viewTag === eventData.viewTag) {
          onSelection({
            chosenOption: eventData.chosenOption,
            highlightedText: eventData.highlightedText,
          });
        }
      },
    );

    return () => subscription.remove();
  }, [onSelection]);

  const handleSelection = useCallback(
    (event: { nativeEvent: SelectionEvent }) => {
      onSelection?.(event.nativeEvent);
    },
    [onSelection],
  );

  return (
    <SelectableCodeBlockViewNativeComponent
      ref={nativeRef}
      tokensJson={tokensJson}
      fontFamily={fontFamily}
      fontSize={fontSize}
      lineHeight={lineHeight}
      color={color}
      selectable={selectable}
      wrapLines={wrapLines}
      menuOptions={menuOptions}
      onSelection={Platform.OS === 'ios' ? handleSelection : undefined}
      style={style}
      testID={testID}
    />
  );
};