#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <MJNIndexView.h>
#import "CignaViewController.h"
#import "CignaSpecialitiesViewController.h"
#import "DoctorSpeciality.h"
#import "DoctorSpecialityCell.h"
#import "JSONReader.h"

@interface CignaSpecialitiesViewController () <UITableViewDataSource, UITableViewDelegate, MJNIndexViewDataSource>

@property (nonatomic) NSArray<DoctorSpeciality *> *specialities;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MJNIndexView *indexView;
@property (weak,nonatomic) NSString *title;

- (void)didTapSpecialityCellTitle:(UITapGestureRecognizer *)sender;

@end

@interface CignaSpecialitiesViewControllerTests : XCTestCase

@property (nonatomic) CignaSpecialitiesViewController *cignaSpecialitiesViewController;
@property (nonatomic) id cignaSpecialitiesViewControllerMock;
@property (nonatomic) id doctorMock;

@end

@implementation CignaSpecialitiesViewControllerTests

- (void)setUp {
    [super setUp];
    
    [self stubDoctorSpecialitiesJSONWith:nil];
    
    self.doctorMock = OCMClassMock([DoctorSpeciality class]);
    self.cignaSpecialitiesViewController = [[CignaSpecialitiesViewController alloc] init];
        (void)self.cignaSpecialitiesViewController.view;
    
    self.cignaSpecialitiesViewControllerMock = OCMPartialMock(self.cignaSpecialitiesViewController);
}

- (void)stubDoctorSpecialitiesJSONWith:(NSArray *)doctorSpecialities {
    id JSONReaderMock = OCMClassMock([JSONReader class]);
    OCMStub([JSONReaderMock readJSONFromFile:[OCMArg any]]).andReturn(doctorSpecialities);
}

- (void)testWhenSpecialityCellIsEqualDoctorSpeciality {
    OCMStub([self.doctorMock title]).andReturn(@"Fixture title");
    OCMStub([self.doctorMock definition]).andReturn(@"Fixture definition");
    
    DoctorSpecialityCell *cell = (DoctorSpecialityCell *)[self.cignaSpecialitiesViewController tableView:self.cignaSpecialitiesViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    cell.titleLabel.text = @"Fixture title";
    cell.definitionLabel.text = @"Fixture definition";
    
    XCTAssertEqualObjects(cell.titleLabel.text, [self.doctorMock title]);
    XCTAssertEqualObjects(cell.definitionLabel.text, [self.doctorMock definition]);
}

- (void)testForIndexView {
    
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.getSelectedItemsAfterPanGestureIsFinished, YES);
    XCTAssertEqualObjects(self.cignaSpecialitiesViewController.indexView.font, [UIFont fontWithName:@"HelveticaNeue" size:13.0]);
    XCTAssertEqualObjects(self.cignaSpecialitiesViewController.indexView.selectedItemFont, [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0]);
    XCTAssertEqualObjects(self.cignaSpecialitiesViewController.indexView.curtainColor, nil);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.curtainFade, 5.0);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.curtainStays,NO);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.curtainMoves, YES);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.curtainMargins, NO);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.ergonomicHeight, NO);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.rightMargin, 0.0);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.itemsAligment, NSTextAlignmentCenter);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.maxItemDeflection, 50.0);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.rangeOfDeflection, 5);
    XCTAssertEqualObjects(self.cignaSpecialitiesViewController.indexView.selectedItemFontColor, [UIColor colorWithRed: (240.0/255.0) green:(240.0/255.0) blue:(40.0/255.0) alpha:1]);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.darkening, NO);
    XCTAssertEqual(self.cignaSpecialitiesViewController.indexView.fading, YES);
}

- (void)testWhenCellNotNil {
    UITableViewCell *cell = (UITableViewCell *)[self.cignaSpecialitiesViewController tableView:self.cignaSpecialitiesViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertNotNil(cell);
}

- (void)testThatItAutoFillsCignaSearchFormWhenSpecialityIsTapped {
    id labelMock = OCMClassMock([UILabel class]);
    OCMStub([labelMock text]).andReturn(@"Fixture speciality");
    
    id gestureRecognizerMock = OCMClassMock([UIGestureRecognizer class]);
    OCMStub([gestureRecognizerMock view]).andReturn(labelMock);

    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.cignaSpecialitiesViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    OCMExpect([navigationManagerMock navigateTo:@"/doctors-cigna" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"doctor"], @"Fixture speciality");
        return YES;
    }]]);
    
    [self.cignaSpecialitiesViewController didTapSpecialityCellTitle:gestureRecognizerMock];
    
    OCMVerifyAll(navigationManagerMock);
}

@end
