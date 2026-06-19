package com.selectablecodeblock

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.TextPaint
import android.text.style.BackgroundColorSpan
import android.text.style.CharacterStyle
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.text.style.TypefaceSpan
import android.text.style.UnderlineSpan
import android.util.TypedValue
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import android.widget.TextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.modules.core.DeviceEventManagerModule
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.roundToInt

class SelectableCodeBlockView(context: Context) : TextView(context) {
  private var tokensJson: String = "[]"
  private var menuOptions: Array<String> = arrayOf("Copy")
  private var codeFontFamily: String = "monospace"
  private var codeFontSize: Float = 14f
  private var codeLineHeight: Float = 18f
  private var codeColor: String = "#000000"
  private var codeSelectable: Boolean = true

  init {
    includeFontPadding = false
    setTextIsSelectable(true)
    setBackgroundColor(Color.TRANSPARENT)
    typeface = Typeface.MONOSPACE
    setupSelectionCallback()
    updateTextContent()
  }

  fun setTokensJson(value: String?) {
    tokensJson = value ?: "[]"
    updateTextContent()
  }

  fun setMenuOptions(options: Array<String>) {
    menuOptions = options
    setupSelectionCallback()
  }

  fun setCodeFontFamily(value: String?) {
    codeFontFamily = value ?: "monospace"
    updateTextContent()
  }

  fun setCodeFontSize(value: Float) {
    codeFontSize = if (value > 0f) value else 14f
    updateTextContent()
  }

  fun setCodeLineHeight(value: Float) {
    codeLineHeight = if (value > 0f) value else codeFontSize * 1.25f
    updateTextContent()
  }

  fun setCodeColor(value: String?) {
    codeColor = value ?: "#000000"
    updateTextContent()
  }

  fun setCodeSelectable(value: Boolean) {
    codeSelectable = value
    setTextIsSelectable(value)
  }

  private fun updateTextContent() {
    val baseColor = parseColorOrNull(codeColor) ?: currentTextColor
    setTextColor(baseColor)
    setTextSize(TypedValue.COMPLEX_UNIT_SP, codeFontSize)
    typeface = typefaceFor(codeFontFamily, Typeface.NORMAL)

    val lineHeightPx = codeLineHeight * resources.displayMetrics.scaledDensity
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      setLineHeight(lineHeightPx.roundToInt())
    } else {
      val fontHeight = paint.fontMetricsInt.descent - paint.fontMetricsInt.ascent
      setLineSpacing(lineHeightPx - fontHeight, 1f)
    }

    val builder = SpannableStringBuilder()
    val tokens = parseTokens(tokensJson)

    tokens.forEach { token ->
      val start = builder.length
      builder.append(token.text)
      val end = builder.length

      if (start == end) {
        return@forEach
      }

      (parseColorOrNull(token.color) ?: baseColor).let {
        builder.setSpan(ForegroundColorSpan(it), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }

      parseColorOrNull(token.backgroundColor)?.let {
        builder.setSpan(BackgroundColorSpan(it), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }

      val style = styleFor(token.fontWeight, token.fontStyle)
      if (style != Typeface.NORMAL) {
        builder.setSpan(StyleSpan(style), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }

      if (codeFontFamily.isNotBlank()) {
        builder.setSpan(CodeTypefaceSpan(codeFontFamily, style), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }

      if (token.textDecorationLine?.contains("underline") == true) {
        builder.setSpan(UnderlineSpan(), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }
    }

    text = builder
    setTextIsSelectable(codeSelectable)
  }

  private fun setupSelectionCallback() {
    customSelectionActionModeCallback = object : ActionMode.Callback {
      override fun onCreateActionMode(mode: ActionMode?, menu: Menu?): Boolean = true

      override fun onPrepareActionMode(mode: ActionMode?, menu: Menu?): Boolean {
        menu?.clear()
        menuOptions.forEachIndexed { index, option ->
          menu?.add(0, index, index, option)
        }
        return true
      }

      override fun onActionItemClicked(mode: ActionMode?, item: MenuItem?): Boolean {
        val option = menuOptions.getOrNull(item?.itemId ?: 0) ?: "Copy"
        val selectedText = selectedText()

        if (option == "Copy") {
          val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
          clipboard.setPrimaryClip(ClipData.newPlainText("code", selectedText))
        }

        emitSelection(option, selectedText)
        mode?.finish()
        return true
      }

      override fun onDestroyActionMode(mode: ActionMode?) = Unit
    }
  }

  private fun selectedText(): String {
    val start = selectionStart.coerceAtLeast(0)
    val end = selectionEnd.coerceAtLeast(0)
    if (start == end) {
      return ""
    }

    val from = minOf(start, end)
    val to = maxOf(start, end)
    return text.substring(from, to)
  }

  private fun emitSelection(chosenOption: String, highlightedText: String) {
    val reactContext = context as? ReactContext ?: return
    val params = Arguments.createMap().apply {
      putInt("viewTag", id)
      putString("chosenOption", chosenOption)
      putString("highlightedText", highlightedText)
    }

    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit("SelectableCodeBlockSelection", params)
  }

  private fun parseTokens(json: String): List<CodeToken> {
    return try {
      val array = JSONArray(json)
      (0 until array.length()).mapNotNull { index ->
        val token = array.optJSONObject(index) ?: return@mapNotNull null
        CodeToken(
          text = token.optString("text", ""),
          color = token.optStringOrNull("color"),
          backgroundColor = token.optStringOrNull("backgroundColor"),
          fontWeight = token.optStringOrNull("fontWeight"),
          fontStyle = token.optStringOrNull("fontStyle"),
          textDecorationLine = token.optStringOrNull("textDecorationLine"),
        )
      }
    } catch (_: Exception) {
      emptyList()
    }
  }

  private fun parseColorOrNull(value: String?): Int? {
    if (value.isNullOrBlank()) {
      return null
    }

    return try {
      Color.parseColor(value)
    } catch (_: IllegalArgumentException) {
      null
    }
  }

  private fun styleFor(fontWeight: String?, fontStyle: String?): Int {
    val isBold = fontWeight == "bold" || fontWeight == "600" || fontWeight == "700"
    val isItalic = fontStyle == "italic"

    return when {
      isBold && isItalic -> Typeface.BOLD_ITALIC
      isBold -> Typeface.BOLD
      isItalic -> Typeface.ITALIC
      else -> Typeface.NORMAL
    }
  }

  private fun typefaceFor(fontFamily: String, style: Int): Typeface {
    return if (fontFamily.isBlank() || fontFamily == "monospace" || fontFamily == "Courier") {
      Typeface.create(Typeface.MONOSPACE, style)
    } else {
      Typeface.create(fontFamily, style)
    }
  }

  private data class CodeToken(
    val text: String,
    val color: String?,
    val backgroundColor: String?,
    val fontWeight: String?,
    val fontStyle: String?,
    val textDecorationLine: String?,
  )

  private inner class CodeTypefaceSpan(
    private val fontFamily: String,
    private val style: Int,
  ) : TypefaceSpan(fontFamily) {
    override fun updateDrawState(ds: TextPaint) {
      apply(ds)
    }

    override fun updateMeasureState(paint: TextPaint) {
      apply(paint)
    }

    private fun apply(paint: TextPaint) {
      paint.typeface = typefaceFor(fontFamily, style)
    }
  }
}

private fun JSONObject.optStringOrNull(name: String): String? {
  return if (has(name) && !isNull(name)) optString(name) else null
}