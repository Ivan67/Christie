#import <SWRevealViewController.h>
#import "Constants.h"
#import "MenuViewController.h"
#import "NavigationManager.h"
#import "UIColor+Hex.h"

typedef NS_ENUM(NSInteger, MenuButtonTag) {
    MenuButtonTagMyChristie,
    MenuButtonTagPharmacies,
    MenuButtonTagDoctors,
    MenuButtonTagVision,
    MenuButtonTagDental,
    MenuButtonTagEuropAssist,
    MenuButtonTagPlanDocuments,
    MenuButtonTagLegalDocuments,
    MenuButtonTagSettings
};

@interface MenuViewController () <SWRevealViewControllerDelegate>

@property (weak, nonatomic) UIButton *currentButton;
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

@implementation MenuViewController

- (instancetype)initWithNavigationManager:(NavigationManager *)navigationManager {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _navigationManager = navigationManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.revealViewController.delegate = self;
    self.currentButton = self.myChristieButton;
}

- (void)setCurrentButton:(UIButton *)button {
    _currentButton.backgroundColor = [UIColor clearColor];
    _currentButton = button;
    button.backgroundColor = [UIColor colorWithRGB:0x837469 alpha:0.16];
}

- (NSString *)navigationPathForButton:(UIButton *)button {
    switch (button.tag) {
        case MenuButtonTagMyChristie:
            return @"/my-christie";
        case MenuButtonTagPharmacies:
            return @"/pharmacies";
        case MenuButtonTagDoctors:
            return @"/doctors";
        case MenuButtonTagVision:
            return @"/vision";
        case MenuButtonTagDental:
            return @"/dental";
        case MenuButtonTagEuropAssist:
            return @"/europ-assist";
        case MenuButtonTagPlanDocuments:
            return @"/plan-documents";
        case MenuButtonTagLegalDocuments:
            return @"/legal-documents";
        case MenuButtonTagSettings:
            return @"/settings";
    }
    return nil;
}

- (IBAction)didPressMenuItemButton:(UIButton *)sender {
    self.currentButton = sender;
    [self.navigationManager navigateTo:[self navigationPathForButton:sender]];
    [self.revealViewController revealToggleAnimated:YES];
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    [self.revealViewController.frontViewController.view endEditing:YES];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    switch (position) {
        case FrontViewPositionRight:
            [notificationCenter postNotificationName:MenuWillOpenNotification object:nil];
            break;
        case FrontViewPositionLeft:
            [notificationCenter postNotificationName:MenuWillCloseNotification object:nil];
            break;
        default:
            break;
    }
}

@end
