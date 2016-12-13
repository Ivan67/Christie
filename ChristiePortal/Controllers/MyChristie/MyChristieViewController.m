#import "ClaimsViewController.h"
#import "MyChristieViewController.h"
#import "PickerViewController.h"
#import "User.h"
#import "UIColor+Hex.h"

@interface MyChristieViewController () 

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MyChristieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"My Christie" image:@"menu_mychristie"];
    
    self.scrollView.contentSize = self.contentView.frame.size;

    CGRect titleLabelBounds = self.addressLabel.bounds;
    titleLabelBounds.size.height = CGFLOAT_MAX;
    CGRect minimumTextRect = [self.addressLabel textRectForBounds:titleLabelBounds limitedToNumberOfLines:2];
    
    CGFloat titleLabelHeightDelta = minimumTextRect.size.height - self.addressLabel.frame.size.height;
    CGRect titleFrame = self.addressLabel.frame;
    titleFrame.size.height += titleLabelHeightDelta;
    self.addressLabel.frame = titleFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkInternetAccess];
    User *user = [User sharedUser];
    self.memberNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.memberIDLabel.text = user.oldMemberID;
    self.phoneLabel.text = user.phone;
    self.emailLabel.text = user.email;
    self.countryLabel.text = user.country;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", user.address1, user.address2];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/y";
    self.dateLabel.text = [dateFormatter stringFromDate:user.birthDate];
    
}

- (void)applyNavigationBarTheme {
    [UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRGB:0x418FDE alpha:0.9];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)printCard {
    [self applyNavigationBarTheme];
    
    if (![UIPrintInteractionController isPrintingAvailable]) {
        [self showErrorAlertWithMessage:@"Printing is not available on this device"];
        return;
    }
    
    NSData *cardImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"card"], 1.0);
    if (![UIPrintInteractionController canPrintData:cardImageData]) {
        [self showErrorAlertWithMessage:@"The image format is not supported"];
        return;
    }
    
    UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
    printInteractionController.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Christie card";
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printInteractionController.printInfo = printInfo;
    printInteractionController.showsPageRange = YES;
    printInteractionController.printingItem = cardImageData;
    
    [printInteractionController presentAnimated:YES completionHandler:^(UIPrintInteractionController *controller, BOOL completed, NSError *error) {
        if (!completed && error != nil) {
            NSLog(@"Print failed: %@", error);
        }
    }];
}

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController {
    return self.navigationController;
}

- (void)shareCardViaText {
    [self applyNavigationBarTheme];
    
    if (![MFMessageComposeViewController canSendText]) {
        [self showErrorAlertWithMessage:@"Text messaging is not supported on this device"];
        return;
    }

    MFMessageComposeViewController* messageComposeViewController = [[MFMessageComposeViewController alloc] init];
    messageComposeViewController.messageComposeDelegate = self;
    
    if ([MFMessageComposeViewController canSendSubject]) {
        messageComposeViewController.subject = @"Christie card";
    }
    
    if ([MFMessageComposeViewController canSendAttachments]) {
        NSData *attachment = UIImageJPEGRepresentation([UIImage imageNamed:@"card.png"], 1.0);
        [messageComposeViewController addAttachmentData:attachment typeIdentifier:(NSString *)kUTTypeMessage filename:@"card.png"];
    }
    
    [self presentViewController:messageComposeViewController animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareCardViaEmail {
    [self applyNavigationBarTheme];
    
    if (![MFMailComposeViewController canSendMail]) {
        [self showErrorAlertWithMessage:@"Mailing is not supported on this device"];
        return;
    }
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    mailComposeViewController.subject = @"Christie card";
    [mailComposeViewController setToRecipients:@[@"person1@example.com", @"person2@example.com"]];
    
    NSString *emailBody = @"Add a comment...";
    [mailComposeViewController setMessageBody:emailBody isHTML:NO];
    
    NSData *cardImageData = UIImagePNGRepresentation([UIImage imageNamed:@"card.png"]);
    [mailComposeViewController addAttachmentData:cardImageData mimeType:@"image/png" fileName:@"card.png"];
    
    [self presentViewController:mailComposeViewController animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showShareNoticeAlertWithCompletionBlock:(void(^)())completionBlock {
    [self showAlertWithTitle:@"Notice" message:@"Be careful, don't send your personal data to scammers!" actions:@[
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completionBlock();
        }]
    ]];
}

- (IBAction)showShareCardMenu {
    PickerViewController *pickerViewController = [[PickerViewController alloc] init];
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Share via text" handler:^{
        [self showShareNoticeAlertWithCompletionBlock:^{
            [self shareCardViaText];
        }];
    }]];
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Share via email" handler:^{
        [self showShareNoticeAlertWithCompletionBlock:^{
            [self shareCardViaEmail];
        }];
    }]];
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Print" handler:^{
        [self printCard];
    }]];
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (IBAction)showClaimsView {
    [self.navigationManager navigateTo:@"/my-christie/claims"];
}

@end