#include "SelectableCodeBlockViewShadowNode.h"

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

#include <algorithm>
#include <cmath>
#include <limits>

namespace facebook::react {

const char SelectableCodeBlockMeasuredViewComponentName[] = "SelectableCodeBlockView";

static CGFloat effectiveFontSize(const SelectableCodeBlockViewProps &props)
{
  return props.fontSize > 0 ? props.fontSize : 14.0;
}

static CGFloat effectiveLineHeight(const SelectableCodeBlockViewProps &props)
{
  const auto fontSize = effectiveFontSize(props);
  return props.lineHeight > 0 ? props.lineHeight : std::round(fontSize * 1.25);
}

static UIFont *fontForToken(NSDictionary *token, const SelectableCodeBlockViewProps &props)
{
  const auto fontSize = effectiveFontSize(props);
  NSString *fontFamily = props.fontFamily.empty()
      ? @"Courier"
      : [NSString stringWithUTF8String:props.fontFamily.c_str()];
  UIFont *font = [UIFont fontWithName:fontFamily size:fontSize];

  if (!font) {
    font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
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
  return descriptor ? [UIFont fontWithDescriptor:descriptor size:fontSize] : font;
}

static NSAttributedString *attributedStringForProps(const SelectableCodeBlockViewProps &props)
{
  NSData *jsonData = [[NSString stringWithUTF8String:props.tokensJson.c_str()] dataUsingEncoding:NSUTF8StringEncoding];
  id parsed = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] : nil;
  NSArray *tokens = [parsed isKindOfClass:[NSArray class]] ? (NSArray *)parsed : @[];

  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.minimumLineHeight = effectiveLineHeight(props);
  paragraphStyle.maximumLineHeight = effectiveLineHeight(props);
  paragraphStyle.lineBreakMode = props.wrapLines ? NSLineBreakByWordWrapping : NSLineBreakByClipping;

  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];

  for (id tokenObject in tokens) {
    if (![tokenObject isKindOfClass:[NSDictionary class]]) {
      continue;
    }

    NSDictionary *token = (NSDictionary *)tokenObject;
    NSString *text = [token[@"text"] isKindOfClass:[NSString class]] ? token[@"text"] : @"";

    if (text.length == 0) {
      continue;
    }

    NSDictionary *attributes = @{
      NSFontAttributeName: fontForToken(token, props),
      NSParagraphStyleAttributeName: paragraphStyle
    };
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attributes]];
  }

  return attributedText;
}

static NSArray<NSAttributedString *> *hardLinesForText(NSAttributedString *attributedText)
{
  NSMutableArray<NSAttributedString *> *lines = [[NSMutableArray alloc] init];
  NSString *plainText = attributedText.string;
  NSUInteger lineStart = 0;

  for (NSUInteger index = 0; index < plainText.length; index++) {
    if ([plainText characterAtIndex:index] != '\n') {
      continue;
    }

    NSRange lineRange = NSMakeRange(lineStart, index - lineStart);
    [lines addObject:[attributedText attributedSubstringFromRange:lineRange]];
    lineStart = index + 1;
  }

  if (lineStart < plainText.length) {
    [lines addObject:[attributedText attributedSubstringFromRange:NSMakeRange(lineStart, plainText.length - lineStart)]];
  } else if (lines.count == 0) {
    [lines addObject:[[NSAttributedString alloc] initWithString:@""]];
  }

  return lines;
}

static Size measureUnwrappedAttributedText(NSAttributedString *attributedText, CGFloat lineHeight)
{
  NSArray<NSAttributedString *> *lines = hardLinesForText(attributedText);
  CGFloat measuredWidth = 0;

  for (NSAttributedString *line in lines) {
    if (line.length == 0) {
      continue;
    }

    CTLineRef ctLine = CTLineCreateWithAttributedString((CFAttributedStringRef)line);
    CGFloat lineWidth = static_cast<CGFloat>(CTLineGetTypographicBounds(ctLine, nullptr, nullptr, nullptr));
    measuredWidth = std::max(measuredWidth, std::ceil(lineWidth));
    CFRelease(ctLine);
  }

  return Size{
      static_cast<Float>(std::max<CGFloat>(1, measuredWidth)),
      static_cast<Float>(std::ceil(std::max<NSUInteger>(static_cast<NSUInteger>(1), lines.count) * lineHeight))};
}

static Size measureWrappedAttributedText(
    NSAttributedString *attributedText,
    CGFloat width,
    CGFloat lineHeight)
{
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX / 4.0)];
  textContainer.lineFragmentPadding = 0;
  textContainer.lineBreakMode = NSLineBreakByWordWrapping;

  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [layoutManager ensureLayoutForTextContainer:textContainer];

  CGRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
  CGFloat measuredHeight = std::ceil(usedRect.size.height);

  if (measuredHeight <= 0) {
    measuredHeight = lineHeight;
  }

  return Size{
      static_cast<Float>(width),
      static_cast<Float>(measuredHeight)};
}

Size SelectableCodeBlockViewShadowNode::measureContent(
    const LayoutContext & /*layoutContext*/,
    const LayoutConstraints &layoutConstraints) const
{
  const auto &props = getConcreteProps();
  NSAttributedString *attributedText = attributedStringForProps(props);

  if (attributedText.length == 0) {
    return layoutConstraints.clamp(Size{0, static_cast<Float>(effectiveLineHeight(props))});
  }

  const CGFloat lineHeight = effectiveLineHeight(props);
  const bool hasFiniteMaxWidth = std::isfinite(layoutConstraints.maximumSize.width);
  Size measuredSize = !props.wrapLines || !hasFiniteMaxWidth
      ? measureUnwrappedAttributedText(attributedText, lineHeight)
      : measureWrappedAttributedText(attributedText, layoutConstraints.maximumSize.width, lineHeight);

  return layoutConstraints.clamp(measuredSize);
}

} // namespace facebook::react