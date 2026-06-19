#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef SelectableCodeBlockViewNativeComponent_h
#define SelectableCodeBlockViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface SelectableCodeBlockView : RCTViewComponentView <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray<NSString *> *menuOptions;
- (void)handleCopyAction;
@end

NS_ASSUME_NONNULL_END

#endif /* SelectableCodeBlockViewNativeComponent_h */