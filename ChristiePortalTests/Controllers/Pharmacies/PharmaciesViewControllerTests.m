#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DataManager.h"
#import "PharmaciesViewController.h"
#import "Pharmacy.h"
#import "PharmacyDetailsViewController.h"
#import "PharmacySearchViewController.h"

@interface PharmaciesViewController () <PharmacySearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *favoritePharmacyButton;
@property (weak, nonatomic) IBOutlet UILabel *favoritePharmacyName;
@property (weak, nonatomic) IBOutlet UILabel *favoritePharmacyAddress;
@property (weak, nonatomic) IBOutlet UILabel *noFavoritePharamcyLabel;

@property (weak, nonatomic) IBOutlet UIView *recentPharmacy1Button;
@property (weak, nonatomic) IBOutlet UILabel *recentPharmacy1Name;
@property (weak, nonatomic) IBOutlet UILabel *recentPharmacy1Address;
@property (weak, nonatomic) IBOutlet UIView *recentPharmacy2Button;
@property (weak, nonatomic) IBOutlet UILabel *recentPharmacy2Name;
@property (weak, nonatomic) IBOutlet UILabel *recentPharmacy2Address;
@property (weak, nonatomic) IBOutlet UILabel *noRecentPharmaciesLabel;

- (IBAction)showSearchView;
- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender;

@end

@interface PharmaciesViewControllerTests : XCTestCase

@property (nonatomic) PharmaciesViewController *pharmaciesViewController;
@property (nonatomic) id pharmaciesViewControllerMock;

@end

@implementation PharmaciesViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.pharmaciesViewController = [[PharmaciesViewController alloc] init];
    (void)self.pharmaciesViewController.view;
    
    self.pharmaciesViewControllerMock = OCMPartialMock(self.pharmaciesViewController);
}

- (id)favoritePharmacyMock {
    id pharmacyMock = OCMClassMock([Pharmacy class]);
    OCMStub([pharmacyMock valueForKey:@"favorite"]).andReturn(@YES);
    OCMStub([pharmacyMock address]).andReturn(@"Fixture address");
    OCMStub([pharmacyMock displayName]).andReturn(@"Fixture name");
    return pharmacyMock;
}

- (id)recentPharmacyMock {
    id pharmacyMock = OCMClassMock([Pharmacy class]);
    OCMStub([pharmacyMock valueForKey:@"lastViewed"]).andReturn([NSDate dateWithTimeIntervalSince1970:0]);
    OCMStub([pharmacyMock address]).andReturn(@"Fixture address");
    OCMStub([pharmacyMock displayName]).andReturn(@"Fixture name");
    return pharmacyMock;
}

- (void)stubFetchedPharmaciesAndReturn:(NSArray *)fetchedPharmacies {
    id dataManagerMock = OCMClassMock([DataManager class]);
    OCMStub([dataManagerMock sharedManager]).andReturn(dataManagerMock);
    OCMStub([dataManagerMock fetchPharmacies]).andReturn(fetchedPharmacies);
}

- (void)testThatItShowsFavoritePharmacyWhenThereIsOne {
    [self stubFetchedPharmaciesAndReturn:@[[self favoritePharmacyMock]]];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmaciesViewController.favoritePharmacyName.text, @"Fixture name");
    XCTAssertEqualObjects(self.pharmaciesViewController.favoritePharmacyAddress.text, @"Fixture address");
    XCTAssertFalse(self.pharmaciesViewController.favoritePharmacyButton.hidden);
    XCTAssertTrue(self.pharmaciesViewController.noFavoritePharamcyLabel.hidden);
}

- (void)testThatItHidesFavoritePharmacyWhenThereIsNoFavoritePharamcy {
    [self stubFetchedPharmaciesAndReturn:nil];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    
    XCTAssertTrue(self.pharmaciesViewController.favoritePharmacyButton.hidden);
    XCTAssertFalse(self.pharmaciesViewController.noFavoritePharamcyLabel.hidden);
}

- (void)testThatItShowsFirstRecentPharmacyWhenThereIsOnlyOneRecentPharmacy {
    [self stubFetchedPharmaciesAndReturn:@[[self recentPharmacyMock]]];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmaciesViewController.recentPharmacy1Name.text, @"Fixture name");
    XCTAssertEqualObjects(self.pharmaciesViewController.recentPharmacy1Address.text, @"Fixture address");
    XCTAssertFalse(self.pharmaciesViewController.recentPharmacy1Button.hidden);
    XCTAssertTrue(self.pharmaciesViewController.noRecentPharmaciesLabel.hidden);
}

- (void)testThatItShowsSecondRecentPharmacyWhenThereAreTwoRecentPharmacies {
    [self stubFetchedPharmaciesAndReturn:@[
        [self recentPharmacyMock],
        [self recentPharmacyMock]
    ]];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.pharmaciesViewController.recentPharmacy2Name.text, @"Fixture name");
    XCTAssertEqualObjects(self.pharmaciesViewController.recentPharmacy2Address.text, @"Fixture address");
    XCTAssertFalse(self.pharmaciesViewController.recentPharmacy2Button.hidden);
    XCTAssertTrue(self.pharmaciesViewController.noRecentPharmaciesLabel.hidden);
}

- (void)testThatItHidesRecentPharmaciesWhenThereAreNoRecentPharmacies {
    [self stubFetchedPharmaciesAndReturn:nil];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    
    XCTAssertTrue(self.pharmaciesViewController.recentPharmacy1Button.hidden);
    XCTAssertTrue(self.pharmaciesViewController.recentPharmacy2Button.hidden);
    XCTAssertFalse(self.pharmaciesViewController.noRecentPharmaciesLabel.hidden);
}

- (id)stubNavigationManager {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.pharmaciesViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    return navigationManagerMock;
}

- (void)testThatItShowsPharmacySearchScreenWhenSearchButtonIsPressed {
    OCMExpect([[self.pharmaciesViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(id viewController) {
        XCTAssertTrue([viewController isKindOfClass:[UINavigationController class]]);
        XCTAssertEqual([viewController viewControllers].count, 1u);
        XCTAssertTrue([[viewController viewControllers][0] isKindOfClass:[PharmacySearchViewController class]]);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self.pharmaciesViewController showSearchView];
    
    OCMVerifyAll(self.pharmaciesViewControllerMock);
}

- (id)gestureRecognizerMockWithView:(UIView *)view {
    id gestureRecognizerMock = OCMClassMock([UIGestureRecognizer class]);
    OCMStub([gestureRecognizerMock view]).andReturn(view);
    return gestureRecognizerMock;
}

- (void)expectNavigationManager:(id)navigationManager toNavigateToPharmacyDetailsWithPharmacy:(id)pharmacy {
    OCMExpect([navigationManager navigateTo:@"/pharmacies/details" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqual(parameters[@"pharmacy"], pharmacy);
        return YES;
    }]]);
}

- (void)testThatItShowsPharmacyDetailsScreenWhenFavoritePharmacyIsTapped {
    id pharmacyMock = [self favoritePharmacyMock];
    [self stubFetchedPharmaciesAndReturn:@[pharmacyMock]];
    
    id navigationManagerMock = [self stubNavigationManager];
    id gestureRecognizerMock = [self gestureRecognizerMockWithView:self.pharmaciesViewController.favoritePharmacyButton];
    [self expectNavigationManager:navigationManagerMock toNavigateToPharmacyDetailsWithPharmacy:pharmacyMock];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    [self.pharmaciesViewController handleTapGesture:gestureRecognizerMock];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsPharmacyDetailsScreenWhenFirstRecentPharmacyIsTapped {
    id pharmacyMock = [self recentPharmacyMock];
    [self stubFetchedPharmaciesAndReturn:@[pharmacyMock]];
    
    id navigationManagerMock = [self stubNavigationManager];
    id gestureRecognizerMock = [self gestureRecognizerMockWithView:self.pharmaciesViewController.recentPharmacy1Button];
    [self expectNavigationManager:navigationManagerMock toNavigateToPharmacyDetailsWithPharmacy:pharmacyMock];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    [self.pharmaciesViewController handleTapGesture:gestureRecognizerMock];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsPharmacyDetailsScreenWhenSecondRecentPharmacyIsTapped {
    id pharmacy1Mock = [self recentPharmacyMock];
    id pharmacy2Mock = [self recentPharmacyMock];
    [self stubFetchedPharmaciesAndReturn:@[pharmacy1Mock, pharmacy2Mock]];
    
    id navigationManagerMock = [self stubNavigationManager];
    id gestureRecognizerMock = [self gestureRecognizerMockWithView:self.pharmaciesViewController.recentPharmacy2Button];
    [self expectNavigationManager:navigationManagerMock toNavigateToPharmacyDetailsWithPharmacy:pharmacy2Mock];
    
    [self.pharmaciesViewController viewWillAppear:NO];
    [self.pharmaciesViewController handleTapGesture:gestureRecognizerMock];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsPharmacyDetailsScreenWhenSearchDelegateIsCalled {
    OCMStub([[self.pharmaciesViewControllerMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)();
        [invocation getArgument:&completionHandler atIndex:3];
        if (completionHandler != nil) {
            completionHandler();
        }
    });
    
    id pharmacyMock = OCMClassMock([Pharmacy class]);
    id pharmacySearchViewControllerMock = OCMClassMock([PharmacySearchViewController class]);
    id navigationControllerMock = OCMClassMock([UINavigationController class]);
    OCMStub([pharmacySearchViewControllerMock navigationController]).andReturn(navigationControllerMock);
    
    OCMExpect([[navigationControllerMock ignoringNonObjectArgs] pushViewController:[OCMArg checkWithBlock:^BOOL(id detailsViewController) {
        XCTAssertTrue([detailsViewController isKindOfClass:[PharmacyDetailsViewController class]]);
        XCTAssertEqual([detailsViewController pharmacy], pharmacyMock);
        return YES;
    }] animated:NO]);
    
    [self.pharmaciesViewControllerMock pharmacySearchViewController:pharmacySearchViewControllerMock didSelectPharmacy:pharmacyMock];
    
    OCMVerifyAll(navigationControllerMock);
}

@end
