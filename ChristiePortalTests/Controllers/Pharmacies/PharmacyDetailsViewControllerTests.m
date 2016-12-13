#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "Pharmacy.h"
#import "OpenStatusBadge.h"
#import "PharmacyDetailsViewController.h"

@interface PharmacyDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *headerTextView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *pharmacyHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *pharmacyOpenStatusBadge;
@property (weak, nonatomic) IBOutlet UILabel *pharmacyHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *photoHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *photoOpenStatuBadge;
@property (weak, nonatomic) IBOutlet UILabel *photoHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *minuteClinicHoursView;
@property (weak, nonatomic) IBOutlet OpenStatusBadge *minuteClinicOpenStatusBadge;
@property (weak, nonatomic) IBOutlet UILabel *minuteClinicHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *storeServicesView;
@property (weak, nonatomic) IBOutlet UILabel *storeServicesLabel;

@end

@interface PharmacyDetailsViewControllerTests : XCTestCase

@property (nonatomic) PharmacyDetailsViewController *pharmacyDetailsViewController;
@property (nonatomic) id pharmacyMock;

@end

@implementation PharmacyDetailsViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.pharmacyDetailsViewController = [[PharmacyDetailsViewController alloc] init];
    (void)self.pharmacyDetailsViewController.view;
    
    self.pharmacyMock = OCMClassMock([Pharmacy class]);
    self.pharmacyDetailsViewController.navigationParameters = @{
        @"pharmacy": self.pharmacyMock
    };
}

- (void)testWhenAdressLabelIsEqualToAddresDisplayNameAndPhoneNumber {
    
    OCMStub([self.pharmacyMock address]).andReturn(@"Fixture address");
    OCMStub([self.pharmacyMock displayName]).andReturn(@"Fixture code");
    OCMStub([self.pharmacyMock phone]).andReturn(@"Fixture phone");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertTrue([self.pharmacyDetailsViewController.headerTextView.text containsString:@"Fixture code"]);
    XCTAssertTrue([self.pharmacyDetailsViewController.headerTextView.text containsString:@"Fixture address"]);
    XCTAssertTrue([self.pharmacyDetailsViewController.headerTextView.text containsString:@"Fixture phone"]);
}

- (void)testWhenButtonHasStatusOpenNow {
    
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.pharmacyOpenStatusBadge.openTitle , @"OPEN NOW");
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.photoOpenStatuBadge.openTitle , @"OPEN NOW");
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.minuteClinicOpenStatusBadge.openTitle , @"OPEN NOW");
}

- (void)testWhenButtonHasStatusCloseNow {
    
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.pharmacyOpenStatusBadge.closedTitle, @"CLOSED NOW");
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.photoOpenStatuBadge.closedTitle, @"CLOSED NOW");
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.minuteClinicOpenStatusBadge.closedTitle, @"CLOSED NOW");
}

- (void)testWhenPharmacyHoursLabelIsEqualOpen24Hours {
    
    OCMStub([self.pharmacyMock pharmacyHours]).andReturn(@"Fixture pharmacy hours");
    OCMStub([self.pharmacyMock isOpen24Hours]).andReturn(YES);
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.pharmacyHoursLabel.text, @"24/7");
}

- (void)testWhenPhotoHoursLabelIsEqualOpen24Hours {
 
    OCMStub([self.pharmacyMock photoHours]).andReturn(@"Fixture photo hours");
    OCMStub([self.pharmacyMock hasPhotoOpen24Hours]).andReturn(YES);
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.photoHoursLabel.text, @"24/7");
}

- (void)testWhenMinuteClinickHoursLabelIsEqualOpen24Hours {
    
    OCMStub([self.pharmacyMock minuteClinicHours]).andReturn(@"Fixture minute clinick hours");
    OCMStub([self.pharmacyMock hasMinuteClinicOpen24Hours]).andReturn(YES);
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmacyDetailsViewController.minuteClinicHoursLabel.text, @"24/7");
}

- (void)testWhenServicesLabelTextNotNil {
    
    OCMStub([self.pharmacyMock service]).andReturn(@"Fixture services");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertEqual(self.pharmacyDetailsViewController.storeServicesLabel.text, [[self.pharmacyMock service] stringByReplacingOccurrencesOfString: @", " withString:@"\n"]);
}

- (void)testWhenPharmacyHoursIsEqualNil {
    
    OCMStub([self.pharmacyMock pharmacyHours]).andReturn(@"");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];

    XCTAssertFalse(self.pharmacyDetailsViewController.photoHoursLabel.hidden);
}

- (void)testWhenPhotoHoursIsEqualNil {
    
    OCMStub([self.pharmacyMock photoHours]).andReturn(@"");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertFalse(self.pharmacyDetailsViewController.photoHoursLabel.hidden);
}

- (void)testWhenMinuteClinickHoursIsEqualNil {
    
    OCMStub([self.pharmacyMock minuteClinicHours]).andReturn(@"");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertFalse(self.pharmacyDetailsViewController.minuteClinicHoursLabel.hidden);
}

- (void)testWhenStoreServiceHoursIsEqualNil {
    
    OCMStub([self.pharmacyMock service]).andReturn(@"");
    
    [self.pharmacyDetailsViewController viewWillAppear:NO];
    
    XCTAssertFalse(self.pharmacyDetailsViewController.storeServicesLabel.hidden);
}


@end
