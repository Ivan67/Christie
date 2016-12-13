#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "CignaViewController.h"

@interface CignaViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *doctorSpecialityField;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIButton *specialitiesButton;

- (IBAction)showLocationField;
- (IBAction)showSpecialitiesView;
- (IBAction)showCignaSearchView;
- (void)showTuftsView;

@end

@interface CignaViewControllerTests : XCTestCase

@property (nonatomic) CignaViewController *cignaViewController;
@property (nonatomic) id cignaViewControllerMock;

@end

@implementation CignaViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.cignaViewController = [[CignaViewController alloc] init];
    (void)self.cignaViewController.view;
    
    self.cignaViewControllerMock = OCMPartialMock(self.cignaViewController);
}

- (void)testThatItGetsInitialDoctorSpecialityTextFromNavigationParameters {
    self.cignaViewController.navigationParameters = @{
        @"doctor": @"Fixture doctor speciality"
    };
    [self.cignaViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.cignaViewController.doctorSpecialityField.text, @"Fixture doctor speciality");
}

- (void)testThatItShowsAddLocationWhenButtonIsPressed{
    
    [self.cignaViewController showLocationField];
    
    XCTAssertTrue(self.cignaViewController.addLocationButton.hidden);
}

- (void)testThatItShowsSpecialitiesScreenWhenSpecialitiesButtonIsPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.cignaViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    [self.cignaViewControllerMock showSpecialitiesView];
    
    OCMVerify([navigationManagerMock navigateTo:@"/doctors-cigna/specialities"]);
}

- (void)testThatItShowsCignaSearchResultsScreenWhenSearchButtonIsPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.cignaViewControllerMock navigationManager]).andReturn(navigationManagerMock);

    OCMExpect([navigationManagerMock navigateTo:@"/doctors-cigna/search" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"doctor"], @"Fixture doctor");
        XCTAssertEqualObjects(parameters[@"location"], @"Fixture search location");
        return YES;
    }]]);
    
    [self.cignaViewController showLocationField];
    self.cignaViewController.doctorSpecialityField.text = @"Fixture doctor";
    self.cignaViewController.locationField.text = @"Fixture search location";
    [self.cignaViewControllerMock showCignaSearchView];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsDoctorScreenWhenTuftsButtonIsPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.cignaViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    [self.cignaViewControllerMock showTuftsView];
    
    OCMVerify([navigationManagerMock navigateTo:@"/doctors-tufts"]);
}

@end
