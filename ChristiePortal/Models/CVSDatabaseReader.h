#import <Foundation/Foundation.h>

@class FMDatabase;

@interface CVSDatabaseReader : NSObject

@property (nonatomic, readonly) FMDatabase *database;

- (instancetype)initWithDatabase:(FMDatabase *)database;

- (NSUInteger)numberOfEntriesInTable:(NSString *)tableName;
- (void)readTable:(NSString *)tableName usingBlock:(void(^)(NSDictionary *row))block;

@end
