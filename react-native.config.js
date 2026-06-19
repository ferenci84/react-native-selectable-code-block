module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        sourceDir: './android',
        packageImportPath: 'import com.selectablecodeblock.SelectableCodeBlockPackage;',
        packageInstance: 'new SelectableCodeBlockPackage()',
        libraryName: 'SelectableCodeBlockViewSpec',
        componentDescriptors: ['SelectableCodeBlockViewComponentDescriptor'],
      },
    },
  },
};