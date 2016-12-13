//
//  CVSDatabaseReaderTests.m
//  ChristiePortal
//
//  Created by Sergey on 11/21/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <FMDB.h>
#import "CVSDatabaseReader.h"

@interface CVSDatabaseReaderTests : XCTestCase

@property (nonatomic) FMDatabase *database;

@end

@implementation CVSDatabaseReaderTests

- (void)setUp {
    [super setUp];
    
    self.database = [[FMDatabase alloc] initWithPath:nil];
    self.database.traceExecution = YES;
    self.database.logsErrors = YES;
    
    [self.database open];
    [self.database executeStatements:@""
     "BEGIN TRANSACTION;\n"
     "CREATE TABLE fixture_table(id INTEGER);\n"
     "INSERT INTO fixture_table VALUES(1);\n"
     "INSERT INTO fixture_table VALUES(2);\n"
     "INSERT INTO fixture_table VALUES(3);\n"
     "COMMIT;"
     ];
}

- (void)testThatItCalculatesNumberOfEntries {
    CVSDatabaseReader *reader = [[CVSDatabaseReader alloc] initWithDatabase:self.database];
    
    NSUInteger numberOfEntries = [reader numberOfEntriesInTable:@"fixture_table"];
    
    XCTAssertEqual(numberOfEntries, 3u);
}

- (void)testThatItReadsDataFromDatabase {
    CVSDatabaseReader *reader = [[CVSDatabaseReader alloc] initWithDatabase:self.database];
    
    NSMutableArray *readEntries = [[NSMutableArray alloc] init];
    [reader readTable:@"fixture_table" usingBlock:^(NSDictionary *row) {
        [readEntries addObject:row[@"id"]];
    }];
    
    NSArray *expectedEntries = @[@1, @2, @3];
    XCTAssertEqualObjects(readEntries, expectedEntries);
}

@end
