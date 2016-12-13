#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "DistanceFormatter.h"
#import "LocationMonitor.h"
#import "Pharmacy.h"
#import "PharmacySearchCell.h"
#import "PharmacySearchOptionCell.h"
#import "PharmacySearchViewController.h"

@interface PharmacySearchViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *pharmaciesTableView;
@property (weak, nonatomic) IBOutlet UIView *searchOptionsView;
@property (weak, nonatomic) IBOutlet UITableView *searchOptionsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchOptionsButton;

- (IBAction)startSearch;
- (IBAction)toggleSearchOptions;

@end

@interface PharmacySearchViewControllerTests : XCTestCase

@property (nonatomic) PharmacySearchViewController *pharmacySearchViewController;
@property (nonatomic) id pharmacySearchViewControllerMock;

@end

@implementation PharmacySearchViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.pharmacySearchViewController = [[PharmacySearchViewController alloc] init];
    (void)self.pharmacySearchViewController.view;
    
    self.pharmacySearchViewControllerMock = OCMPartialMock(self.pharmacySearchViewController);
    
    id distanceFormatterMock = OCMClassMock([DistanceFormatter class]);
    OCMStub([[distanceFormatterMock ignoringNonObjectArgs] stringFromDistance:0]).andDo((^(NSInvocation *invocation) {
        CLLocationDistance distance;
        [invocation getArgument:&distance atIndex:2];
        NSString *formattedDistance = [NSString stringWithFormat:@"%.0f", distance];
        [invocation setReturnValue:&formattedDistance];
    }));
}

- (id)pharmacyMockWithName:(NSString *)name {
    id pharmacyMock = OCMClassMock([Pharmacy class]);
    OCMStub([pharmacyMock displayName]).andReturn(name);
    return pharmacyMock;
}

- (id)pharmacyMockWithName:(NSString *)name address:(NSString *)address distance:(CLLocationDistance)distance {
    id pharmacyMock = [self pharmacyMockWithName:name];
    OCMStub([pharmacyMock address]).andReturn(address);
    OCMStub([pharmacyMock valueForKey:@"address"]).andReturn(address);
    OCMStub([pharmacyMock distanceToLocation:[OCMArg any]]).andReturn(distance);
    return pharmacyMock;
}

- (id)pharmacyMockWithName:(NSString *)name service:(NSString *)service {
    id pharmacyMock = [self pharmacyMockWithName:name];;
    OCMStub([pharmacyMock service]).andReturn(service);
    OCMStub([pharmacyMock valueForKey:@"service"]).andReturn(service);
    return pharmacyMock;
}

- (void)stubFetchedPharmaciesAndReturn:(NSArray *)fetchedPharmacies {
    id dataManagerMock = OCMClassMock([DataManager class]);
    OCMStub([dataManagerMock sharedManager]).andReturn(dataManagerMock);
    OCMStub([dataManagerMock fetchPharmaciesNearLocation:[OCMArg any]]).andReturn(fetchedPharmacies);
}

- (void)testThatItShowsSearchOptionsDropdownWhenMoreOptionsButtonIsPressed {
    [self.pharmacySearchViewController toggleSearchOptions];
    
    XCTAssertFalse(self.pharmacySearchViewController.searchOptionsView.hidden);
}

- (void)testThatItHidesSearchOptionsDropdownWhenMoreOptionsButtonIsPressedTwice {
    [self.pharmacySearchViewController toggleSearchOptions];
    [self.pharmacySearchViewController toggleSearchOptions];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    XCTAssertTrue(self.pharmacySearchViewController.searchOptionsView.hidden);
}

- (void)testThatItReturnsCorrectNumberOfRowsForPharmaciesTableView {
    NSArray *pharmacies = @[
        OCMClassMock([Pharmacy class]),
        OCMClassMock([Pharmacy class]),
        OCMClassMock([Pharmacy class])
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    NSInteger numberOfRows = [self.pharmacySearchViewController tableView:self.pharmacySearchViewController.pharmaciesTableView numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 3);
}

- (void)testThatItCreatesCellsForPharmaciesTableView {
    NSArray *pharmacies = @[[self pharmacyMockWithName:@"Fixture name" address:@"Fixture address" distance:100]];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    PharmacySearchCell *cell = (PharmacySearchCell *)[self.pharmacySearchViewController tableView:self.pharmacySearchViewController.pharmaciesTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqualObjects(cell.nameLabel.text, @"Fixture name");
    XCTAssertEqualObjects(cell.addressLabel.text, @"Fixture address");
    XCTAssertEqualObjects(cell.distanceLabel.text, @"100");
}

- (void)testThatItCallsDelegate {
    id pharmacyMock = [self pharmacyMockWithName:@"Fixture name" address:@"Fixture address" distance:100];
    [self stubFetchedPharmaciesAndReturn:@[pharmacyMock]];
    [self.pharmacySearchViewController viewWillAppear:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    id delegateMock = OCMProtocolMock(@protocol(PharmacySearchViewControllerDelegate));
    self.pharmacySearchViewController.delegate = delegateMock;
    
    [self.pharmacySearchViewControllerMock tableView:self.pharmacySearchViewController.pharmaciesTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    OCMVerify([delegateMock pharmacySearchViewController:self.pharmacySearchViewController didSelectPharmacy:pharmacyMock]);
}

- (void)testThatItSortsPharmaciesByDistance {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 3" address:nil distance:300],
        [self pharmacyMockWithName:@"Fixture pharmacy 2" address:nil distance:200],
        [self pharmacyMockWithName:@"Fixture pharmacy 1" address:nil distance:100]
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    [self.pharmacySearchViewController startSearch];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    NSMutableArray *namesOfPharmaciesAfterSearch = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < pharmacies.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)i inSection:0];
        PharmacySearchCell *cell = (PharmacySearchCell *)[self.pharmacySearchViewController tableView:self.pharmacySearchViewController.pharmaciesTableView cellForRowAtIndexPath:indexPath];
        [namesOfPharmaciesAfterSearch addObject:cell.nameLabel.text];
    }
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 3", @"Fixture pharmacy 2", @"Fixture pharmacy 1"];
    XCTAssertEqualObjects(namesOfPharmaciesAfterSearch, expectedPharmacies);
}

- (NSInteger)numberOfRowsInTableView:(UITableView *)tableView {
    return [self.pharmacySearchViewController tableView:tableView numberOfRowsInSection:0];
}

- (NSArray *)cellsInTableView:(UITableView *)tableView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self numberOfRowsInTableView:tableView]; i++) {
        UITableViewCell *cell = [self.pharmacySearchViewController tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cells addObject:cell];
    }
    return cells;
}

- (NSArray *)namesOfPharmaciesInPharmaciesTableView {
    NSArray *cells  = [self cellsInTableView:self.pharmacySearchViewController.pharmaciesTableView];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (PharmacySearchCell *cell in cells) {
        [names addObject:cell.nameLabel.text];
    }
    return names;
}

- (void)testThatItFiltersPharmaciesBySearchTermLowercase {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 1" address:@"Lorem ipsum" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 2" address:@"Ipsum dolor" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 3" address:@"Lorem ipsum dolor" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 4" address:@"Should not be found" distance:0]
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    self.pharmacySearchViewController.searchField.text = @"ipsum";
    [self.pharmacySearchViewController startSearch];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 1", @"Fixture pharmacy 2", @"Fixture pharmacy 3"];
    NSArray *pharmaciesAfterSearch = [self namesOfPharmaciesInPharmaciesTableView];
    
    XCTAssertEqualObjects(pharmaciesAfterSearch, expectedPharmacies);
}

- (void)testThatItFiltersPharmaciesBySearchTermUppercase {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 1" address:@"Lorem ipsum" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 2" address:@"Ipsum dolor" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 3" address:@"Lorem ipsum dolor" distance:0],
        [self pharmacyMockWithName:@"Fixture pharmacy 4" address:@"Should not be found" distance:0]
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    self.pharmacySearchViewController.searchField.text = @"IPSUM";
    [self.pharmacySearchViewController startSearch];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 1", @"Fixture pharmacy 2", @"Fixture pharmacy 3"];
    NSArray *pharmaciesAfterSearch = [self namesOfPharmaciesInPharmaciesTableView];
    
    XCTAssertEqualObjects(pharmaciesAfterSearch, expectedPharmacies);
}

- (void)selectSearchOptionWithTitle:(NSString *)title {
    NSArray *searchOptionCells = [self cellsInTableView:self.pharmacySearchViewController.searchOptionsTableView];
    [searchOptionCells enumerateObjectsUsingBlock:^(PharmacySearchOptionCell *cell, NSUInteger idx, BOOL *stop) {
        if ([cell.titleLabel.text isEqualToString:title]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)idx inSection:0];
            [self.pharmacySearchViewController tableView:self.pharmacySearchViewController.searchOptionsTableView didSelectRowAtIndexPath:indexPath];
            *stop = YES;
        }
    }];
}

- (void)testThatItFiltersPharmaciesBySelectedServices {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 1" service:@"24-Hour Pharmacy,Pharmacy,MinuteClinic"],
        [self pharmacyMockWithName:@"Fixture pharmacy 2" service:@"24-Hour Pharmacy,Pharmacy"],
        [self pharmacyMockWithName:@"Fixture pharmacy 3" service:@"Pharmacy,MinuteClinic"],
        [self pharmacyMockWithName:@"Fixture pharmacy 4" service:@"Should not be found"]
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    [self selectSearchOptionWithTitle:@"Pharmacy"];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 1", @"Fixture pharmacy 2", @"Fixture pharmacy 3"];
    NSArray *pharmaciesAfterSearch = [self namesOfPharmaciesInPharmaciesTableView];
    
    XCTAssertEqualObjects(pharmaciesAfterSearch, expectedPharmacies);
}

- (void)testThatItShowsFilteredOutPharmaciesBackWhenServiceIsDelselect {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 1" service:@"Pharmacy"],
        [self pharmacyMockWithName:@"Fixture pharmacy 2" service:@"Should not be found"]
    ];
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    [self selectSearchOptionWithTitle:@"Pharmacy"];
    [self selectSearchOptionWithTitle:@"Pharmacy"];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 1", @"Fixture pharmacy 2"];
    NSArray *pharmaciesAfterSearch = [self namesOfPharmaciesInPharmaciesTableView];
    
    XCTAssertEqualObjects(pharmaciesAfterSearch, expectedPharmacies);
}

- (void)testThatItFiltersPharmaciesByOpenNow {
    NSArray<Pharmacy *> *pharmacies = @[
        [self pharmacyMockWithName:@"Fixture pharmacy 1"],
        [self pharmacyMockWithName:@"Fixture pharmacy 2"],
        [self pharmacyMockWithName:@"Fixture pharmacy 3"],
    ];
    OCMStub([pharmacies[1] isOpenAt:[OCMArg any]]).andReturn(YES);
    [self stubFetchedPharmaciesAndReturn:pharmacies];
    [self.pharmacySearchViewController viewWillAppear:NO];
    
    [self selectSearchOptionWithTitle:@"Open Now"];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    NSArray *expectedPharmacies = @[@"Fixture pharmacy 2"];
    NSArray *pharmaciesAfterSearch = [self namesOfPharmaciesInPharmaciesTableView];
    
    XCTAssertEqualObjects(pharmaciesAfterSearch, expectedPharmacies);
}

- (void)testThatItReloadsPharmaciesWhenLocationChanges {
    id pharmacyMock = [self pharmacyMockWithName:@"Fixture pharmacy" address:nil distance:0];
    [self stubFetchedPharmaciesAndReturn:@[pharmacyMock]];
    [self.pharmacySearchViewController viewWillAppear:NO];

    pharmacyMock = [self pharmacyMockWithName:@"Fixture pharmacy" address:nil distance:100];
    [self stubFetchedPharmaciesAndReturn:@[pharmacyMock]];
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationMonitorLocationDidChangeNotification object:nil userInfo:@{
        LocationMonitorLocationKey: [[CLLocation alloc] init]
    }];

    PharmacySearchCell *cell = [[self cellsInTableView:self.pharmacySearchViewController.pharmaciesTableView] firstObject];
    XCTAssertEqualObjects(cell.distanceLabel.text, @"100");
}

@end
