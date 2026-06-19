"use strict";

const React = require('react');
const { DeviceEventEmitter, findNodeHandle, Platform } = require('react-native');
const SelectableCodeBlockViewNativeComponent = require('./SelectableCodeBlockViewNativeComponent.js');
const { jsx } = require('react/jsx-runtime');

const SelectableCodeBlockView = ({
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
  const nativeRef = React.useRef(null);
  const tokensJson = React.useMemo(() => JSON.stringify(tokens), [tokens]);

  React.useEffect(() => {
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

  const handleSelection = React.useCallback(
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
    wrapLines,
    menuOptions,
    onSelection: Platform.OS === 'ios' ? handleSelection : undefined,
    style,
    testID,
  });
};

exports.SelectableCodeBlockView = SelectableCodeBlockView;