//
//  CVSDatabase.h
//  ChristiePortal
//
//  Created by Sergey on 16/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface CVSDatabaseReader : NSObject

@property (nonatomic, readonly) FMDatabase *database;

- (instancetype)initWithDatabase:(FMDatabase *)database;

- (NSUInteger)numberOfEntriesInTable:(NSString *)tableName;
- (void)readTable:(NSString *)tableName usingBlock:(void(^)(NSDictionary *row))block;

@end
