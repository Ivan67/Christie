#import <BlocksKit/BlocksKit.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "APIClient.h"
#import "CignaViewController.h"
#import "Doctor.h"
#import "DoctorCell.h"
#import "DoctorSpeciality.h"
#import "DoctorsDropdownCell.h"
#import "JSONReader.h"
#import "TuftsSearchViewController.h"

@interface TuftsSearchViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *doctorsTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchSuggestionsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

- (void)showCignaView;

@end

@interface TuftsSearchViewControllerTests : XCTestCase

@property (nonatomic) TuftsSearchViewController *tuftsSearchViewController;
@property (nonatomic) id tuftsSearchViewControllerMock;

@end

@implementation TuftsSearchViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.tuftsSearchViewController = [[TuftsSearchViewController alloc] init];
    (void)self.tuftsSearchViewController.view;
    
    self.tuftsSearchViewControllerMock = OCMPartialMock(self.tuftsSearchViewController);
}

- (void)stubFetchedDoctorsAndReturn:(NSArray *)fetchedDoctors {
    id APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([APIClientMock sharedClient]).andReturn(APIClientMock);
    OCMStub([APIClientMock fetchDoctors]).andReturn(fetchedDoctors);
}

- (void)stubDoctorSpecialitiesJSONWith:(NSArray *)doctorSpecialities {
    id JSONReaderMock = OCMClassMock([JSONReader class]);
    OCMStub([JSONReaderMock readJSONFromFile:[OCMArg any]]).andReturn(doctorSpecialities);
}

- (void)testThatItReturnsCorrectNumberOfRowsForDoctosTableView {
    [self stubFetchedDoctorsAndReturn:@[
        OCMStub([Doctor class]),
        OCMStub([Doctor class]),
        OCMStub([Doctor class])
    ]];
    [self stubDoctorSpecialitiesJSONWith:nil];
    [self.tuftsSearchViewController viewWillAppear:NO];
    
    NSInteger numberOfRows = [self.tuftsSearchViewController tableView:self.tuftsSearchViewController.doctorsTableView numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 3);
}

- (id)doctorMockWithName:(NSString *)name address:(NSString *)address type:(NSString *)type {
    id doctorMock = OCMClassMock([Doctor class]);
    OCMStub([doctorMock name]).andReturn(name);
    OCMStub([doctorMock address]).andReturn(address);
    OCMStub([(Doctor *)doctorMock type]).andReturn(type);
    return doctorMock;
}

- (id)doctorSpecialityMockWithTitle:(NSString *)title {
    id doctorSpecialityMock = OCMClassMock([DoctorSpeciality class]);
    OCMStub([doctorSpecialityMock title]).andReturn(title);
    OCMStub([doctorSpecialityMock valueForKey:@"title"]).andReturn(title);
    return doctorSpecialityMock;
}

- (void)testThatItCreatesCellsForDoctorsTableView {
    NSArray *doctorMocks = @[[self doctorMockWithName:@"Fixture doctor" address:@"Fixture address" type:@"Fixture type"]];
    [self stubFetchedDoctorsAndReturn:doctorMocks];
    [self stubDoctorSpecialitiesJSONWith:nil];
    [self.tuftsSearchViewController viewWillAppear:NO];
    
    DoctorCell *cell = (DoctorCell *)[self.tuftsSearchViewController tableView:self.tuftsSearchViewController.doctorsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqualObjects(cell.nameLabel.text, @"Fixture doctor");
    XCTAssertEqualObjects(cell.addressLabel.text, @"Fixture address");
}

- (NSInteger)numberOfRowsInTableView:(UITableView *)tableView {
    return [self.tuftsSearchViewController tableView:tableView numberOfRowsInSection:0];
}

- (NSArray *)cellsInTableView:(UITableView *)tableView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self numberOfRowsInTableView:tableView]; i++) {
        UITableViewCell *cell = [self.tuftsSearchViewController tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cells addObject:cell];
    }
    return cells;
}

- (void)testThatItShowsSearchSuggestionsForLowercaseQuery {
    [self stubDoctorSpecialitiesJSONWith:@[
        @{@"title": @"Lorem ipsum"},
        @{@"title": @"Ipsum dolor"},
        @{@"title": @"Lorem ipsum dolor"},
        @{@"title": @"Should not be found"},
    ]];
    [self.tuftsSearchViewController viewWillAppear:NO];
    
    self.tuftsSearchViewController.searchField.text = @"ipsum";
    [self.tuftsSearchViewController.searchField sendActionsForControlEvents:UIControlEventEditingChanged];
    
    NSArray *suggestions = [[self cellsInTableView:self.tuftsSearchViewController.searchSuggestionsTableView] bk_map:^id(DoctorsDropdownCell *cell) {
        return cell.dropdownTextLabel.text;
    }];
    NSArray *expectedSuggestions = @[@"Lorem ipsum", @"Ipsum dolor", @"Lorem ipsum dolor"];
    XCTAssertEqualObjects(suggestions, expectedSuggestions);
}

- (void)testThatItShowsSearchSuggestionsForUppercaseQuery {
    [self stubDoctorSpecialitiesJSONWith:@[
        @{@"title": @"Lorem ipsum"},
        @{@"title": @"Ipsum dolor"},
        @{@"title": @"Lorem ipsum dolor"},
        @{@"title": @"Should not be found"},
    ]];
    [self.tuftsSearchViewController viewWillAppear:NO];
    
    self.tuftsSearchViewController.searchField.text = @"ipsum";
    [self.tuftsSearchViewController.searchField sendActionsForControlEvents:UIControlEventEditingChanged];
    
    NSArray *suggestions = [[self cellsInTableView:self.tuftsSearchViewController.searchSuggestionsTableView] bk_map:^id(DoctorsDropdownCell *cell) {
        return cell.dropdownTextLabel.text;
    }];
    NSArray *expectedSuggestions = @[@"Lorem ipsum", @"Ipsum dolor", @"Lorem ipsum dolor"];
    XCTAssertEqualObjects(suggestions, expectedSuggestions);
}

- (void)testThatItShowsCignaSearchScreenWhenCignaButtonIsPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.tuftsSearchViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    [self.tuftsSearchViewControllerMock showCignaView];
    
    OCMVerify([navigationManagerMock navigateTo:@"/doctors-cigna"]);
}

@end
