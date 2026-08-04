#import "SelectableCodeBlockView.h"

#import <react/renderer/components/SelectableCodeBlockViewSpec/EventEmitters.h>
#import <react/renderer/components/SelectableCodeBlockViewSpec/Props.h>
#import <react/renderer/components/SelectableCodeBlockViewSpec/RCTComponentViewHelpers.h>

#import "SelectableCodeBlockViewComponentDescriptor.h"
#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@class SelectableCodeBlockView;

static UIColor *SelectableCodeBlockColorFromString(NSString *colorString, UIColor *fallback);

@interface SelectableCodeTextView : UITextView
@property (nonatomic, weak) SelectableCodeBlockView *parentCodeBlockView;
@end

@implementation SelectableCodeTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  if (action == @selector(copy:)) {
    return [self.parentCodeBlockView.menuOptions containsObject:@"Copy"];
  }

  return NO;
}

- (void)copy:(id)sender
{
  [self.parentCodeBlockView handleCopyAction];
}

@end

@interface SelectableCodeBlockView () <RCTSelectableCodeBlockViewViewProtocol>
@end

@implementation SelectableCodeBlockView {
  NSString *_tokensJson;
  NSString *_fontFamily;
  NSString *_baseColor;
  CGFloat _fontSize;
  CGFloat _lineHeight;
  BOOL _selectable;
  BOOL _wrapLines;
  BOOL _needsTextUpdateAfterRecycle;
  std::vector<std::string> _menuOptionsVector;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<SelectableCodeBlockViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const SelectableCodeBlockViewProps>();
    _props = defaultProps;

    _tokensJson = @"[]";
    _fontFamily = @"Courier";
    _baseColor = @"#000000";
    _fontSize = 14.0;
    _lineHeight = 18.0;
    _selectable = YES;
    _wrapLines = NO;
    _needsTextUpdateAfterRecycle = NO;
    _menuOptions = @[@"Copy"];

    SelectableCodeTextView *textView = [[SelectableCodeTextView alloc] init];
    textView.parentCodeBlockView = self;
    _textView = textView;
    _textView.delegate = self;
    _textView.editable = NO;
    _textView.selectable = YES;
    _textView.scrollEnabled = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textContainerInset = UIEdgeInsetsZero;
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.textContainer.lineBreakMode = NSLineBreakByClipping;
    _textView.userInteractionEnabled = YES;
    _textView.dataDetectorTypes = UIDataDetectorTypeNone;
    _textView.text = @"";

    self.contentView = _textView;
    self.userInteractionEnabled = YES;
  }

  return self;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  _textView.attributedText = nil;
  _textView.selectedRange = NSMakeRange(0, 0);
  _needsTextUpdateAfterRecycle = YES;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _textView.frame = self.bounds;
  _textView.textContainer.lineBreakMode = _wrapLines ? NSLineBreakByWordWrapping : NSLineBreakByClipping;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<SelectableCodeBlockViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<SelectableCodeBlockViewProps const>(props);

  BOOL needsTextUpdate = _needsTextUpdateAfterRecycle;

  if (oldViewProps.tokensJson != newViewProps.tokensJson) {
    _tokensJson = [NSString stringWithUTF8String:newViewProps.tokensJson.c_str()];
    needsTextUpdate = YES;
  }

  if (oldViewProps.fontFamily != newViewProps.fontFamily) {
    _fontFamily = [NSString stringWithUTF8String:newViewProps.fontFamily.c_str()];
    needsTextUpdate = YES;
  }

  if (oldViewProps.color != newViewProps.color) {
    _baseColor = [NSString stringWithUTF8String:newViewProps.color.c_str()];
    needsTextUpdate = YES;
  }

  if (oldViewProps.fontSize != newViewProps.fontSize) {
    _fontSize = newViewProps.fontSize > 0 ? newViewProps.fontSize : 14.0;
    needsTextUpdate = YES;
  }

  if (oldViewProps.lineHeight != newViewProps.lineHeight) {
    _lineHeight = newViewProps.lineHeight > 0 ? newViewProps.lineHeight : round(_fontSize * 1.25);
    needsTextUpdate = YES;
  }

  if (oldViewProps.selectable != newViewProps.selectable) {
    _selectable = newViewProps.selectable;
    _textView.selectable = _selectable;
  }

  if (oldViewProps.wrapLines != newViewProps.wrapLines) {
    _wrapLines = newViewProps.wrapLines;
    _textView.textContainer.lineBreakMode = _wrapLines ? NSLineBreakByWordWrapping : NSLineBreakByClipping;
    needsTextUpdate = YES;
  }

  if (oldViewProps.menuOptions != newViewProps.menuOptions) {
    _menuOptionsVector = newViewProps.menuOptions;

    NSMutableArray<NSString *> *options = [[NSMutableArray alloc] init];
    for (const auto& option : _menuOptionsVector) {
      [options addObject:[NSString stringWithUTF8String:option.c_str()]];
    }
    _menuOptions = options;
  }

  if (needsTextUpdate) {
    [self updateAttributedText];
    _needsTextUpdateAfterRecycle = NO;
  }

  [super updateProps:props oldProps:oldProps];
}

- (void)handleCopyAction
{
  NSRange selectedRange = _textView.selectedRange;
  NSString *selectedText = @"";

  if (selectedRange.location != NSNotFound && selectedRange.length > 0) {
    selectedText = [_textView.text substringWithRange:selectedRange];
    [UIPasteboard generalPasteboard].string = selectedText;
  }

  if (auto eventEmitter = std::static_pointer_cast<const SelectableCodeBlockViewEventEmitter>(_eventEmitter)) {
    SelectableCodeBlockViewEventEmitter::OnSelection selectionEvent = {
      .chosenOption = "Copy",
      .highlightedText = std::string([selectedText UTF8String])
    };
    eventEmitter->onSelection(selectionEvent);
  }
}

- (void)updateAttributedText
{
  NSData *jsonData = [_tokensJson dataUsingEncoding:NSUTF8StringEncoding];
  id parsed = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] : nil;
  NSArray *tokens = [parsed isKindOfClass:[NSArray class]] ? (NSArray *)parsed : @[];

  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
  UIFont *baseFont = [self baseFontWithTraitsForToken:nil];
  UIColor *baseTextColor = SelectableCodeBlockColorFromString(_baseColor, [UIColor labelColor]);
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.minimumLineHeight = _lineHeight;
  paragraphStyle.maximumLineHeight = _lineHeight;
  paragraphStyle.lineBreakMode = _wrapLines ? NSLineBreakByWordWrapping : NSLineBreakByClipping;

  NSDictionary *baseAttributes = @{
    NSFontAttributeName: baseFont,
    NSForegroundColorAttributeName: baseTextColor,
    NSParagraphStyleAttributeName: paragraphStyle
  };

  for (id tokenObject in tokens) {
    if (![tokenObject isKindOfClass:[NSDictionary class]]) {
      continue;
    }

    NSDictionary *token = (NSDictionary *)tokenObject;
    NSString *text = [token[@"text"] isKindOfClass:[NSString class]] ? token[@"text"] : @"";
    if (text.length == 0) {
      continue;
    }

    NSMutableDictionary *attributes = [baseAttributes mutableCopy];
    NSString *color = [token[@"color"] isKindOfClass:[NSString class]] ? token[@"color"] : nil;
    NSString *backgroundColor = [token[@"backgroundColor"] isKindOfClass:[NSString class]] ? token[@"backgroundColor"] : nil;
    NSString *textDecorationLine = [token[@"textDecorationLine"] isKindOfClass:[NSString class]] ? token[@"textDecorationLine"] : nil;

    if (color.length > 0) {
      attributes[NSForegroundColorAttributeName] = SelectableCodeBlockColorFromString(color, baseTextColor);
    }

    if (backgroundColor.length > 0) {
      attributes[NSBackgroundColorAttributeName] = SelectableCodeBlockColorFromString(backgroundColor, [UIColor clearColor]);
    }

    attributes[NSFontAttributeName] = [self baseFontWithTraitsForToken:token];

    if ([textDecorationLine containsString:@"underline"]) {
      attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }

    NSAttributedString *attributedToken = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [attributedText appendAttributedString:attributedToken];
  }

  _textView.attributedText = attributedText;
}

- (UIFont *)baseFontWithTraitsForToken:(NSDictionary * _Nullable)token
{
  CGFloat size = _fontSize > 0 ? _fontSize : 14.0;
  UIFont *font = nil;

  if (_fontFamily.length > 0) {
    font = [UIFont fontWithName:_fontFamily size:size];
  }

  if (!font) {
    font = [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
  }

  if (!token) {
    return font;
  }

  NSString *fontWeight = [token[@"fontWeight"] isKindOfClass:[NSString class]] ? token[@"fontWeight"] : @"";
  NSString *fontStyle = [token[@"fontStyle"] isKindOfClass:[NSString class]] ? token[@"fontStyle"] : @"";
  UIFontDescriptorSymbolicTraits traits = font.fontDescriptor.symbolicTraits;

  if ([fontWeight isEqualToString:@"bold"] || [fontWeight isEqualToString:@"600"] || [fontWeight isEqualToString:@"700"]) {
    traits |= UIFontDescriptorTraitBold;
  }

  if ([fontStyle isEqualToString:@"italic"]) {
    traits |= UIFontDescriptorTraitItalic;
  }

  UIFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
  return descriptor ? [UIFont fontWithDescriptor:descriptor size:size] : font;
}

static UIColor *SelectableCodeBlockColorFromString(NSString *colorString, UIColor *fallback)
{
  if (![colorString isKindOfClass:[NSString class]] || colorString.length == 0) {
    return fallback;
  }

  NSString *hex = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
  if ([hex hasPrefix:@"#"]) {
    hex = [hex substringFromIndex:1];
  }

  if (hex.length == 3) {
    unichar r = [hex characterAtIndex:0];
    unichar g = [hex characterAtIndex:1];
    unichar b = [hex characterAtIndex:2];
    hex = [NSString stringWithFormat:@"%C%C%C%C%C%C", r, r, g, g, b, b];
  }

  if (hex.length != 6 && hex.length != 8) {
    return fallback;
  }

  unsigned int value = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hex];
  if (![scanner scanHexInt:&value]) {
    return fallback;
  }

  CGFloat alpha = 1.0;
  CGFloat red = 0.0;
  CGFloat green = 0.0;
  CGFloat blue = 0.0;

  if (hex.length == 8) {
    alpha = ((value >> 24) & 0xFF) / 255.0;
    red = ((value >> 16) & 0xFF) / 255.0;
    green = ((value >> 8) & 0xFF) / 255.0;
    blue = (value & 0xFF) / 255.0;
  } else {
    red = ((value >> 16) & 0xFF) / 255.0;
    green = ((value >> 8) & 0xFF) / 255.0;
    blue = (value & 0xFF) / 255.0;
  }

  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

Class<RCTComponentViewProtocol> SelectableCodeBlockViewCls(void)
{
  return SelectableCodeBlockView.class;
}

@end