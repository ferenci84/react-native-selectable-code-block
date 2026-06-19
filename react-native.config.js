module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        packageImportPath: 'import com.selectablecodeblock.SelectableCodeBlockPackage;',
        packageInstance: 'new SelectableCodeBlockPackage()',
      },
    },
  },
};