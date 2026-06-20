# Selectable Code Block Example

This is a compact React Native example for exercising the native selectable code block component.

It demonstrates:

- natural native height measurement without an explicit height
- wrapped and unwrapped line layout
- `maxHeight` through ordinary React Native layout style
- light/dark styling
- selection callback handling

To turn this into a full generated app, create native projects in this directory with the React Native CLI and keep `App.tsx` as the entry component:

```sh
npm install
npx react-native init SelectableCodeBlockExample --version 0.82.1 --directory .
npm run ios
```