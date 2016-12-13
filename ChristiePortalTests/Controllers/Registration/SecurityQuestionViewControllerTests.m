#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "APIClient.h"
#import "SecurityQuestionViewController.h"

@interface SecurityQuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *questionsDropdownButton;
@property (weak, nonatomic) IBOutlet UITableView *questionsDropdownTableView;
@property (weak, nonatomic) IBOutlet UITextField *answerField;

@property (nonatomic) NSArray *questions;
@property (nonatomic) NSUInteger questionIndex;

- (IBAction)continueRegistration;
- (void)requestQuestions;

@end

@interface SecurityQuestionViewControllerTests : XCTestCase

@property (nonatomic) SecurityQuestionViewController *securityQuestionViewController;
@property (nonatomic) id securityQuestionViewControllerMock;
@property (nonatomic) id APIClientMock;

@end

@implementation SecurityQuestionViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.securityQuestionViewController = [[SecurityQuestionViewController alloc] init];
    self.securityQuestionViewControllerMock = OCMPartialMock(self.securityQuestionViewController);
    (void)self.securityQuestionViewController.view;
    
    self.APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([self.APIClientMock sharedClient]).andReturn(self.APIClientMock);
}

- (void)testThatItShowsErrorWhenAswerIsEmpty {
    self.securityQuestionViewController.answerField.text = nil;
    [self.securityQuestionViewControllerMock continueRegistration];
    
    OCMVerify([self.securityQuestionViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your answer"]);
        return YES;
    }]]);
}

- (void)testThatItSendsGetRequest {
    
    [self.securityQuestionViewController requestQuestions];
    
    OCMVerify([self.APIClientMock GET:@"questions" parameters:nil
                              success:[OCMArg any] failure:[OCMArg any]]);
}

- (void)testThatItShowWhenCellNotNil {
    
    UITableViewCell *cell = (UITableViewCell *)[self.securityQuestionViewController tableView:self.securityQuestionViewController.questionsDropdownTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertNotNil(cell);
}

- (void)testThatItShowWhenQuestionsNotNil{
    
    self.securityQuestionViewController.questions = @[@"text"];
    
    XCTAssertNotNil(self.securityQuestionViewController.questions);
}

- (void)testsThatItShowWhenquestionsDropdownButtonTitleLabelFontNotNil {
    
    self.securityQuestionViewController.questionsDropdownButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.00];
    
    XCTAssertNotNil(self.securityQuestionViewController.questionsDropdownButton.titleLabel.font);
}

- (void)testsThatItShowWhenquestionsDropdownButtonTitleLabelTextColorNotNil {
    
    self.securityQuestionViewController.questionsDropdownButton.titleLabel.textColor = [UIColor whiteColor];
    
    XCTAssertNotNil(self.securityQuestionViewController.questionsDropdownButton.titleLabel.textColor);
}

- (void)testThatItSendsPostRequest {
    
    self.securityQuestionViewController.answerField.text = @"Fixture answer";
    
    self.securityQuestionViewController.navigationParameters = @{
        @"userID": @"Fixture user ID"
    };
    self.securityQuestionViewController.questions = @[@{
        @"id" : @"1",
        @"text" : @"2"
    }];
    
    OCMExpect([self.APIClientMock POST:@"answers" parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        NSDictionary *answerInfo = parameters[@"answers"];
        XCTAssertEqualObjects(answerInfo[@"text"], @"Fixture answer");
        XCTAssertEqualObjects(answerInfo[@"links"][@"user"], @"Fixture user ID");
        XCTAssertEqualObjects(answerInfo[@"links"][@"question"], @"1");
        return YES;
    }] success:[OCMArg any] failure:[OCMArg any]]);
    
    [self.securityQuestionViewControllerMock viewWillAppear:NO];
    [self.securityQuestionViewControllerMock continueRegistration];
    
    OCMVerifyAll(self.APIClientMock);
}

- (void)testThatItWhenQuestionsCountLessThanSecurityQuestionsIndex {
    
    self.securityQuestionViewController.questionIndex = 5;
    self.securityQuestionViewController.questions = @[@"1"];
    
    [self.securityQuestionViewControllerMock continueRegistration];
    
    XCTAssertLessThan(self.securityQuestionViewController.questions.count, self.securityQuestionViewController.questionIndex);
    
}

- (void)testWhenSQuestionsIndexLessThanQuestionCount{
    
    self.securityQuestionViewController.questionIndex = 1;
    self.securityQuestionViewController.questions = @[@"1", @"2"];
    
    [self.securityQuestionViewControllerMock continueRegistration];
    
    XCTAssertLessThan(self.securityQuestionViewController.questionIndex, self.securityQuestionViewController.questions.count);
}

@end