import React, { useCallback, useEffect, useMemo, useRef } from 'react';
import { DeviceEventEmitter, findNodeHandle, Platform } from 'react-native';
import SelectableCodeBlockViewNativeComponent from './SelectableCodeBlockViewNativeComponent.js';
import { jsx } from 'react/jsx-runtime';

export const SelectableCodeBlockView = ({
  tokens,
  fontFamily,
  fontSize,
  lineHeight,
  color,
  selectable = true,
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
      (eventData) => {
        const viewTag = findNodeHandle(nativeRef.current);
        if (viewTag === eventData.viewTag) {
          onSelection({
            chosenOption: eventData.chosenOption,
            highlightedText: eventData.highlightedText,
          });
        }
      }
    );

    return () => subscription.remove();
  }, [onSelection]);

  const handleSelection = useCallback(
    (event) => {
      onSelection?.(event.nativeEvent);
    },
    [onSelection]
  );

  return jsx(SelectableCodeBlockViewNativeComponent, {
    ref: nativeRef,
    tokensJson,
    fontFamily,
    fontSize,
    lineHeight,
    color,
    selectable,
    menuOptions,
    onSelection: Platform.OS === 'ios' ? handleSelection : undefined,
    style,
    testID,
  });
};