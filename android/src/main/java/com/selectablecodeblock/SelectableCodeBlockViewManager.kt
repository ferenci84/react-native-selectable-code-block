package com.selectablecodeblock

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.SelectableCodeBlockViewManagerDelegate
import com.facebook.react.viewmanagers.SelectableCodeBlockViewManagerInterface

@ReactModule(name = SelectableCodeBlockViewManager.NAME)
class SelectableCodeBlockViewManager : SimpleViewManager<SelectableCodeBlockView>(),
  SelectableCodeBlockViewManagerInterface<SelectableCodeBlockView> {
  private val managerDelegate: ViewManagerDelegate<SelectableCodeBlockView> =
    SelectableCodeBlockViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<SelectableCodeBlockView> = managerDelegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): SelectableCodeBlockView {
    return SelectableCodeBlockView(context)
  }

  @ReactProp(name = "tokensJson")
  override fun setTokensJson(view: SelectableCodeBlockView, value: String?) {
    view.setTokensJson(value)
  }

  @ReactProp(name = "fontFamily")
  override fun setFontFamily(view: SelectableCodeBlockView, value: String?) {
    view.setCodeFontFamily(value)
  }

  @ReactProp(name = "fontSize")
  override fun setFontSize(view: SelectableCodeBlockView, value: Float) {
    view.setCodeFontSize(value)
  }

  @ReactProp(name = "lineHeight")
  override fun setLineHeight(view: SelectableCodeBlockView, value: Float) {
    view.setCodeLineHeight(value)
  }

  @ReactProp(name = "color")
  override fun setColor(view: SelectableCodeBlockView, value: String?) {
    view.setCodeColor(value)
  }

  @ReactProp(name = "selectable")
  override fun setSelectable(view: SelectableCodeBlockView, value: Boolean) {
    view.setCodeSelectable(value)
  }

  @ReactProp(name = "menuOptions")
  override fun setMenuOptions(view: SelectableCodeBlockView, value: ReadableArray?) {
    val options = if (value != null) {
      Array(value.size()) { index -> value.getString(index) ?: "" }
    } else {
      arrayOf("Copy")
    }

    view.setMenuOptions(options)
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
    return MapBuilder.builder<String, Any>()
      .put("topSelection", MapBuilder.of("registrationName", "onSelection"))
      .build()
  }

  companion object {
    const val NAME = "SelectableCodeBlockView"
  }
}