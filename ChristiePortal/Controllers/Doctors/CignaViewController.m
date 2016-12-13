#import "CignaViewController.h"

@interface CignaViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *doctorSpecialityField;
@property (nonatomic) UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *specialitiesButton;

@end

@implementation CignaViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationParameters[@"doctor"] != nil) {
        self.doctorSpecialityField.text = self.navigationParameters[@"doctor"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Search a Doctor" image:@"menu_doctors"];
    
    self.doctorSpecialityField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
   
    UIButton *tuftsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat tuftsButtonHeight = self.navigationController.navigationBar.frame.size.height * 0.6;
    CGFloat tuftsButtonWidth = self.navigationController.navigationBar.frame.size.height + tuftsButtonHeight/2;
    tuftsButton.frame = CGRectMake(0, 0, tuftsButtonWidth, tuftsButtonHeight);
    tuftsButton.adjustsImageWhenHighlighted = NO;
    [tuftsButton setTitle:@"Tufts" forState:UIControlStateNormal];
    tuftsButton.layer.cornerRadius = 4;
    tuftsButton.layer.borderWidth = 1;
    tuftsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [tuftsButton addTarget:self action:@selector(showTuftsView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tuftsButton];
}

- (void)showTuftsView {
    [self.navigationManager navigateTo:@"/doctors-tufts"];
}

- (IBAction)showLocationField {
    self.addLocationButton.hidden = YES;
    
    UILabel *labelLocation = [[UILabel alloc]initWithFrame:CGRectMake(self.doctorSpecialityField.frame.origin.x, self.specialitiesButton.frame.origin.y + self.specialitiesButton.frame.size.height, self.doctorSpecialityField.frame.size.width, self.doctorSpecialityField.frame.size.height)];
    [labelLocation setTextColor:[UIColor whiteColor]];
    labelLocation.text = @"Location";
    labelLocation.textAlignment =  NSTextAlignmentLeft;
    [labelLocation setFont:[UIFont systemFontOfSize:15]];
    [self.overlayView addSubview:labelLocation];
    
    self.locationField = [[UITextField alloc]initWithFrame:CGRectMake(self.doctorSpecialityField.frame.origin.x, self.addLocationButton.frame.origin.y, self.doctorSpecialityField.frame.size.width, self.doctorSpecialityField.frame.size.height)];
    [self.locationField setBackgroundColor:[UIColor whiteColor]];
    [self.locationField setFont:[UIFont systemFontOfSize:15]];
    self.locationField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.locationField.delegate = self;
    [self.overlayView addSubview: self.locationField];
}

- (IBAction)showCignaSearchView {
    [self.navigationManager navigateTo:@"/doctors-cigna/search" withParameters:@{
        @"doctor": self.doctorSpecialityField.text != nil ? self.doctorSpecialityField.text : @"",
        @"location": self.locationField.text != nil ? self.locationField.text : @""
    }];
}

- (IBAction)showSpecialitiesView {
    [self.navigationManager navigateTo:@"/doctors-cigna/specialities"];
}

@end
