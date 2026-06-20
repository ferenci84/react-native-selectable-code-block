import React, { useMemo, useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
  useColorScheme,
} from 'react-native';
import {
  SelectableCodeBlockView,
  type SelectableCodeToken,
} from '@ferenci84/react-native-selectable-code-block';

const longLine = `const greeting = "Selectable code should measure itself, wrap when asked, and remain horizontally scrollable when wrapping is disabled.";`;
const multilineCode = `function greet(name: string) {
  const normalized = name.trim() || "friend";
  return \`Hello, \${normalized}!\`;
}

console.log(greet("Crystal Lattice"));`;

function tokenize(code: string, colors: { text: string; keyword: string; string: string; comment: string }) {
  const tokens: SelectableCodeToken[] = [];
  const pattern = /(const|function|return|console|log|string)|("[^"]*"|`[^`]*`)|(\/\/.*)/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = pattern.exec(code)) !== null) {
    if (match.index > lastIndex) {
      tokens.push({ text: code.slice(lastIndex, match.index), color: colors.text });
    }

    const text = match[0];
    const color = match[1] ? colors.keyword : match[2] ? colors.string : colors.comment;
    tokens.push({ text, color, fontWeight: match[1] === 'function' ? '700' : undefined });
    lastIndex = match.index + text.length;
  }

  if (lastIndex < code.length) {
    tokens.push({ text: code.slice(lastIndex), color: colors.text });
  }

  return tokens;
}

export default function App() {
  const colorScheme = useColorScheme();
  const dark = colorScheme === 'dark';
  const [wrapLines, setWrapLines] = useState(false);
  const [selected, setSelected] = useState('');
  const colors = {
    background: dark ? '#0b0c0f' : '#f5f6f8',
    panel: dark ? '#16181d' : '#ffffff',
    text: dark ? '#f4f4f5' : '#17181c',
    subtle: dark ? '#a9adb7' : '#5d6470',
    keyword: dark ? '#8ab4ff' : '#1f5fbf',
    string: dark ? '#8fd19e' : '#236f3b',
    comment: dark ? '#a9adb7' : '#68717f',
    border: dark ? '#30343c' : '#d8dce3',
  };
  const longTokens = useMemo(() => tokenize(longLine, colors), [colors]);
  const multilineTokens = useMemo(() => tokenize(multilineCode, colors), [colors]);

  return (
    <SafeAreaView style={[styles.root, { backgroundColor: colors.background }]}>
      <ScrollView contentInsetAdjustmentBehavior="automatic" style={styles.scroll}>
        <View style={styles.header}>
          <Text style={[styles.title, { color: colors.text }]}>Selectable Code Block</Text>
          <View style={styles.toggleRow}>
            <Text style={[styles.toggleLabel, { color: colors.subtle }]}>Wrap lines</Text>
            <Switch value={wrapLines} onValueChange={setWrapLines} />
          </View>
        </View>

        <View style={[styles.panel, { backgroundColor: colors.panel, borderColor: colors.border }]}>
          <SelectableCodeBlockView
            tokens={longTokens}
            fontFamily="Menlo"
            fontSize={14}
            lineHeight={18}
            color={colors.text}
            wrapLines={wrapLines}
            menuOptions={['Copy']}
            onSelection={(event) => setSelected(event.highlightedText)}
            style={styles.code}
          />
        </View>

        <View style={[styles.panel, { backgroundColor: colors.panel, borderColor: colors.border, maxHeight: 180 }]}>
          <SelectableCodeBlockView
            tokens={multilineTokens}
            fontFamily="Menlo"
            fontSize={14}
            lineHeight={18}
            color={colors.text}
            wrapLines={wrapLines}
            menuOptions={['Copy']}
            onSelection={(event) => setSelected(event.highlightedText)}
            style={styles.code}
          />
        </View>

        <Text style={[styles.caption, { color: colors.subtle }]}>
          Selected: {selected || 'nothing selected yet'}
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
  scroll: {
    flex: 1,
  },
  header: {
    gap: 12,
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
  },
  toggleRow: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: 12,
  },
  toggleLabel: {
    fontSize: 16,
  },
  panel: {
    borderRadius: 8,
    borderWidth: StyleSheet.hairlineWidth,
    marginHorizontal: 20,
    marginBottom: 16,
    overflow: 'hidden',
    padding: 12,
  },
  code: {
    flexShrink: 1,
  },
  caption: {
    fontSize: 14,
    paddingHorizontal: 20,
    paddingBottom: 32,
  },
});