#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

+ (NSString *)nibName {
    return NSStringFromClass([self class]);
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
