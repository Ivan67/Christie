#import <Foundation/Foundation.h>

@interface DoctorSpeciality : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *definition;

- (instancetype)initWithTitle:(NSString *)title definition:(NSString *)definition;

@end
