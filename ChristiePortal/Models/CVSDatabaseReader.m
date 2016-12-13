#import <FMDB.h>
#import "CVSDatabaseReader.h"

@implementation CVSDatabaseReader

- (instancetype)initWithDatabase:(FMDatabase *)database {
    if (self = [super init]) {
        _database = database;
    }
    return self;
}

- (NSUInteger)numberOfEntriesInTable:(NSString *)tableName {
    return (NSUInteger)[self.database intForQuery:[NSString stringWithFormat:@"SELECT count(*) FROM %@", tableName]];
}

- (void)readTable:(NSString *)tableName usingBlock:(void(^)(NSDictionary *row))block {
    FMResultSet *resultSet = [self.database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", tableName]];
    while (resultSet.next) {
        block(resultSet.resultDictionary);
    }
}

@end
