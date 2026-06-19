# React Native Selectable Code Block

A small React Native native component for selectable, syntax-colored code blocks.

The component accepts token data as props and builds native attributed text directly:

- iOS renders a `UITextView` with an `NSAttributedString`.
- Android renders a selectable `TextView` with a `SpannableStringBuilder`.

It does not inspect or hide React Native child text views.

## Usage

```tsx
import { SelectableCodeBlockView } from '@ferenci84/react-native-selectable-code-block';

<SelectableCodeBlockView
  tokens={[
    { text: 'const', color: '#c678dd' },
    { text: ' value = ', color: '#abb2bf' },
    { text: '1', color: '#d19a66' },
  ]}
  fontFamily="Courier"
  fontSize={14}
  lineHeight={18}
  color="#abb2bf"
  menuOptions={['Copy']}
/>;
```

## Status

This is an early package created for validating selectable code blocks in a Fabric React Native app.