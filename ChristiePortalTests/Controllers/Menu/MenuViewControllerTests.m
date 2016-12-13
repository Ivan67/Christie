//
//  MenuViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 10/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <SWRevealViewController.h>
#import "Constants.h"
#import "MenuViewController.h"
#import "NavigationManager.h"

@interface MenuViewController () <SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *myChristieButton;
@property (weak, nonatomic) IBOutlet UIButton *pharmaciesButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *visionButton;
@property (weak, nonatomic) IBOutlet UIButton *dentalButton;
@property (weak, nonatomic) IBOutlet UIButton *europAssistButton;
@property (weak, nonatomic) IBOutlet UIButton *planDocumentsButton;
@property (weak, nonatomic) IBOutlet UIButton *legalDocumentsButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

- (IBAction)didPressMenuItemButton:(UIButton *)sender;

@end

@interface MenuViewControllerTests : XCTestCase

@property (nonatomic) id navigationManagerMock;
@property (nonatomic) MenuViewController *menuViewController;

@end

@implementation MenuViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.navigationManagerMock = OCMClassMock([NavigationManager class]);
    self.menuViewController = [[MenuViewController alloc] initWithNavigationManager:self.navigationManagerMock];
    (void)self.menuViewController.view;
}

- (void)verifyThatButton:(UIButton *)button navigatesTo:(NSString *)path {
    OCMExpect([self.navigationManagerMock navigateTo:path]);
    
    [self.menuViewController didPressMenuItemButton:button];
    
    OCMVerifyAll(self.navigationManagerMock);
}

- (void)testThatMenuButtonsWork {
    [self verifyThatButton:self.menuViewController.myChristieButton navigatesTo:@"/my-christie"];
    [self verifyThatButton:self.menuViewController.pharmaciesButton navigatesTo:@"/pharmacies"];
    [self verifyThatButton:self.menuViewController.doctorsButton navigatesTo:@"/doctors"];
    [self verifyThatButton:self.menuViewController.visionButton navigatesTo:@"/vision"];
    [self verifyThatButton:self.menuViewController.dentalButton navigatesTo:@"/dental"];
    [self verifyThatButton:self.menuViewController.europAssistButton navigatesTo:@"/europ-assist"];
    [self verifyThatButton:self.menuViewController.planDocumentsButton navigatesTo:@"/plan-documents"];
    [self verifyThatButton:self.menuViewController.legalDocumentsButton navigatesTo:@"/legal-documents"];
    [self verifyThatButton:self.menuViewController.settingsButton navigatesTo:@"/settings"];
}

- (id)observerMockExpectingNotificaton:(NSString *)name {
    id observerMock = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:name object:nil];
    [[observerMock expect] notificationWithName:name object:[OCMArg any] userInfo:[OCMArg any]];
    return observerMock;
}

- (void)testThatItSendsMenuWillOpenNotificationWhenFrontViewIsRevealed {
    id observerMock = [self observerMockExpectingNotificaton:MenuWillOpenNotification];
    
    [self.menuViewController revealController:nil willMoveToPosition:FrontViewPositionRight];
    
    OCMVerifyAll(observerMock);
}

- (void)testThatItSendsMenuWillCloseNotificationWhenFrontViewIsHhidden {
    id observerMock = [self observerMockExpectingNotificaton:MenuWillCloseNotification];
    
    [self.menuViewController revealController:nil willMoveToPosition:FrontViewPositionLeft];
    
    OCMVerifyAll(observerMock);
}

@end
