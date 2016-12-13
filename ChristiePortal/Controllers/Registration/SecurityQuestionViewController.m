#import "APIClient.h"
#import "LoginViewController.h"
#import "SecurityQuestionViewController.h"

@interface SecurityQuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *questionsDropdownButton;
@property (weak, nonatomic) IBOutlet UITableView *questionsDropdownTableView;
@property (weak, nonatomic) IBOutlet UITextField *answerField;

@property (nonatomic) NSString *userID;
@property (nonatomic) NSArray *questions;
@property (nonatomic) NSUInteger questionIndex;

@end

@implementation SecurityQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestQuestions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    self.userID = self.navigationParameters[@"userID"];
}

- (void)requestQuestions {
    self.questionIndex = 0;
    self.answerField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    [[APIClient sharedClient] GET:@"questions" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.questions = responseObject[@"questions"];
        [self.questionsDropdownTableView reloadData];
        if (self.questions.count > 0) {
            NSDictionary *firstQuestion = [self.questions firstObject];
            [self.questionsDropdownButton setTitle:firstQuestion[@"text"] forState:UIControlStateNormal];
        }
    } failure:nil];
}

- (IBAction)toggleQuestionsDropdown {
    self.questionsDropdownTableView.hidden = !self.questionsDropdownTableView.hidden;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.questionsDropdownTableView) {
        return (NSInteger)self.questions.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.questionsDropdownTableView) {
        static NSString *const CellIdentifier = @"QuestionCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.textLabel.text = self.questions[(NSUInteger)indexPath.row][@"text"];
        cell.textLabel.font = self.questionsDropdownButton.titleLabel.font;
        cell.textLabel.textColor = self.questionsDropdownButton.titleLabel.textColor;

        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.questionsDropdownButton setTitle:self.questions[(NSUInteger)indexPath.row][@"text"] forState:UIControlStateNormal];
    self.questionsDropdownTableView.hidden = YES;
}

- (IBAction)continueRegistration {
    NSString *answer = self.answerField.text;
    [self.answerField resignFirstResponder];
    
    NSString *errorMessage;
    if (answer.length == 0 ) {
        errorMessage = @"Please enter your answer";
    }
    
    if (errorMessage.length != 0) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }

    NSDictionary *parameters = @{
        @"answers": @{
            @"text": self.answerField.text,
            @"links": @{
                @"user": self.userID,
                @"question": self.questions[self.questionIndex][@"id"]
            }
        }
    };
    
    [[APIClient sharedClient] POST:@"answers" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.questionIndex++;
        if (self.questionIndex < self.questions.count) {
            [self.questionsDropdownButton setTitle:self.questions[self.questionIndex][@"text"] forState:UIControlStateNormal];
            self.answerField.text = @"";
        } else {
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationManager navigateTo:@"/login"];
            }];
            [self showAlertWithTitle:@"Congratulations" message:@"Registration successfully completed!" actions:@[OKAction]];
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"completedRegistration"];
        }
    } failure:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.questionsDropdownTableView.hidden = YES;
    return [super textFieldShouldReturn:textField];;
}

@end