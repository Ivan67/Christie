#import <UIKit/UIKit.h>

typedef void (^PickeActionHandler)();

@interface PickerAction : NSObject 

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly, copy) PickeActionHandler handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(PickeActionHandler)handler;

- (instancetype)initWithTitle:(NSString *)title handler:(PickeActionHandler)handler;

@end

@interface PickerViewController : UIViewController

@property (nonatomic, readonly) NSArray<PickerAction *> *actions;

- (void)addAction:(PickerAction *)action;

@end
