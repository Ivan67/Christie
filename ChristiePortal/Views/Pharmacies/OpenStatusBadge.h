#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface OpenStatusBadge : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) IBInspectable NSString *fontName;
@property (nonatomic) IBInspectable CGFloat fontSize;

@property (nonatomic) IBInspectable NSString *openTitle;
@property (nonatomic) IBInspectable NSString *closedTitle;
@property (nonatomic) IBInspectable UIColor *openColor;
@property (nonatomic) IBInspectable UIColor *closedColor;

@property (nonatomic, getter=isOpen) IBInspectable BOOL open;

@end
