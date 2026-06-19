module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        sourceDir: './android',
        cmakeListsPath: '../android/src/main/jni/CMakeLists.txt',
        packageImportPath: 'import com.selectablecodeblock.SelectableCodeBlockPackage;',
        packageInstance: 'new SelectableCodeBlockPackage()',
        libraryName: 'SelectableCodeBlockViewSpec',
        componentDescriptors: ['SelectableCodeBlockViewComponentDescriptor'],
      },
    },
  },
};