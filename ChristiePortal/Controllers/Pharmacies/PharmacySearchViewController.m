#import <BlocksKit/BlocksKit.h>
#import "DataManager.h"
#import "DistanceFormatter.h"
#import "LocationMonitor.h"
#import "Pharmacy.h"
#import "PharmacySearchViewController.h"
#import "PharmacySearchCell.h"
#import "PharmacySearchOptionCell.h"

static NSString *SearchOptionNone = @"None";
static NSString *SearchOptionOpenNow = @"Open Now";

@interface PharmacySearchViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *pharmaciesTableView;
@property (weak, nonatomic) IBOutlet UIView *searchOptionsView;
@property (weak, nonatomic) IBOutlet UITableView *searchOptionsTableView;
@property (weak, nonatomic) IBOutlet UIView *searchOptionsBusyOverlayView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchOptionsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *primaryActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchOptionsActivityIndicator;

@property (nonatomic) NSArray *pharmacies;
@property (nonatomic) NSArray *searchOptions;
@property (nonatomic) NSMutableArray *serviceSelectedFlags;
@property (nonatomic) NSOperationQueue *searchQueue;

@end

@implementation PharmacySearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Search a Pharmacy" image:@"menu_pharmacies"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    self.pharmaciesTableView.rowHeight = UITableViewAutomaticDimension;
    self.pharmaciesTableView.estimatedRowHeight = 90;
    [self.pharmaciesTableView registerNib:[UINib nibWithNibName:[PharmacySearchCell nibName] bundle:nil] forCellReuseIdentifier:[PharmacySearchCell reuseIdentifier]];
    [self.searchOptionsTableView registerNib:[UINib nibWithNibName:[PharmacySearchOptionCell nibName] bundle:nil] forCellReuseIdentifier:[PharmacySearchOptionCell reuseIdentifier]];
    
    self.searchOptions = @[
        SearchOptionNone,
        SearchOptionOpenNow,
        @"24-Hour Pharmacy",
        @"24-Hour Store",
        @"Drive-Thru Pharmacy",
        @"MinuteClinic",
        @"Accepts SNAP",
        @"Accepts WIC",
        @"Pharmacy",
        @"Immunizations",
        @"Home Health Center"
    ];
    self.serviceSelectedFlags = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < self.searchOptions.count; i++) {
        [self.serviceSelectedFlags addObject:@NO];
    }
    [self showSearchOptions:NO animated:NO];
    
    self.searchQueue = [[NSOperationQueue alloc] init];
    self.searchQueue.qualityOfService = NSQualityOfServiceUserInitiated;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findPharmacies) name:LocationMonitorLocationDidChangeNotification object:nil];
    
    [self findPharmacies];
    
    [self.searchField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocationMonitorLocationDidChangeNotification object:nil];
}

- (IBAction)startSearch {
    [self showSearchOptions:NO animated:YES];
    [self findPharmacies];
}

- (IBAction)toggleSearchOptions {
    [self.searchField resignFirstResponder];
    [self showSearchOptions:self.searchOptionsView.hidden animated:YES];
}

- (void)showSearchOptions:(BOOL)show animated:(BOOL)animated {
    CGFloat duration = animated ? 0.15 : 0;
    
    CGRect normalSearchOptionsFrame = self.searchOptionsTableView.frame;
    normalSearchOptionsFrame.origin.y = 0;
    CGRect hiddenSearchOptionsFrame = CGRectOffset(normalSearchOptionsFrame, 0, -self.searchOptionsTableView.frame.size.height);
    
    if (show) {
        self.searchOptionsView.hidden = NO;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.searchOptionsView.alpha = 1;
            self.searchOptionsTableView.frame = normalSearchOptionsFrame;
        } completion:nil];
    } else {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.searchOptionsView.alpha = 0;
            self.searchOptionsTableView.frame = hiddenSearchOptionsFrame;
        } completion:^(BOOL finished) {
            self.searchOptionsView.hidden = YES;
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.pharmaciesTableView) {
        return (NSInteger)self.pharmacies.count;
    }
    if (tableView == self.searchOptionsTableView) {
        return (NSInteger)self.searchOptions.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.pharmaciesTableView) {
        PharmacySearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[PharmacySearchCell reuseIdentifier]];
        
        Pharmacy *pharmacy = self.pharmacies[(NSUInteger)indexPath.row];
        cell.nameLabel.text = pharmacy.displayName;
        cell.addressLabel.text = pharmacy.address;
        
        CLLocation *currentLocation = [LocationMonitor sharedMonitor].location;
        CLLocationDistance currentDistance = [pharmacy distanceToLocation:currentLocation];
        cell.distanceLabel.text = currentDistance > 0 ? [DistanceFormatter stringFromDistance:currentDistance] : nil;
        
        NSDate *currentDate = [NSDate date];
        cell.pharmacyOpenStatusBadge.open = [pharmacy isOpenAt:currentDate];
        cell.storeAndPhotoOpenStatusBadge.open = [pharmacy hasPhotoOpenAt:currentDate];
        
        return cell;
    }
    
    if (tableView == self.searchOptionsTableView) {
        PharmacySearchOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:[PharmacySearchOptionCell reuseIdentifier]];
        
        cell.titleLabel.text = self.searchOptions[(NSUInteger)indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL isSelected = [self.serviceSelectedFlags[(NSUInteger)indexPath.row] boolValue];
        if (isSelected) {
            cell.checkImageView.hidden = NO;
        } else {
            cell.checkImageView.hidden = YES;
        }
        
        return cell;
    }
    
    return nil;
}

- (void)updateSearchOptionsButtonTitle {
    NSIndexSet *selectedServiceIndexes = [self.serviceSelectedFlags indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [(NSNumber *)obj boolValue];
    }];
    if (selectedServiceIndexes.count > 1) {
        [self.searchOptionsButton setTitle:@"Multiple options selected" forState:UIControlStateNormal];
    } else if (selectedServiceIndexes.count == 1) {
        [self.searchOptionsButton setTitle:self.searchOptions[selectedServiceIndexes.firstIndex] forState:UIControlStateNormal];
    } else {
        [self.searchOptionsButton setTitle:@"More options" forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.pharmaciesTableView) {
        [self.delegate pharmacySearchViewController:self didSelectPharmacy:self.pharmacies[(NSUInteger)indexPath.row]];
        return;
    }
    
    if (tableView == self.searchOptionsTableView) {
        NSString *option = self.searchOptions[(NSUInteger)indexPath.row];
        if ([option isEqualToString:SearchOptionNone]) {
            for (NSUInteger i = 0; i < self.serviceSelectedFlags.count; i++) {
                self.serviceSelectedFlags[i] = @NO;
                [self.searchField resignFirstResponder];
                [self showSearchOptions:self.searchOptionsView.hidden animated:YES];
            }
        } else {
            BOOL isSelected = [self.serviceSelectedFlags[(NSUInteger)indexPath.row] boolValue];
            self.serviceSelectedFlags[indexPath.row] = @((BOOL)!isSelected);
        }
        [self findPharmacies];
        [self.searchOptionsTableView reloadData];
        [self updateSearchOptionsButtonTitle];
        return;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showSearchOptions:NO animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self startSearch];
    return [super textFieldShouldReturn:textField];;
}

- (void)findPharmacies {
    static const CGFloat OverlayAnimationDuration = 0.1;
    static const NSUInteger OverlayAnimationOptions = UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:OverlayAnimationDuration delay:0 options:OverlayAnimationOptions animations:^{
        self.searchOptionsBusyOverlayView.alpha = 1;
    } completion:nil];
    
    [self.primaryActivityIndicator startAnimating];
    [self.searchOptionsActivityIndicator startAnimating];
    
    [self findPharmaciesInBackgroundWithCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:OverlayAnimationDuration delay:0 options:OverlayAnimationOptions animations:^{
                self.searchOptionsBusyOverlayView.alpha = 0;
            } completion:nil];
            
            [self.primaryActivityIndicator stopAnimating];
            [self.searchOptionsActivityIndicator stopAnimating];
            
            [self.pharmaciesTableView reloadData];
        });
    }];
}

- (void)findPharmaciesInBackgroundWithCompletionBlock:(void(^)())completionBlock {
    NSBlockOperation *searchOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSDate *startTime = [NSDate date];
        
        // 1. Start with all pharmacies ordered by distance.
        CLLocation *currentLocation = [LocationMonitor sharedMonitor].location;
        self.pharmacies = [[DataManager sharedManager] fetchPharmaciesNearLocation:currentLocation];
        
        // 2. Filter out pharmacies that don't match user-entered text.
        if (self.searchField.text.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@", self.searchField.text];
            self.pharmacies = [self.pharmacies filteredArrayUsingPredicate:predicate];
        }
        
        // 3. And finally, filter pharmacies by selected search options.
        NSIndexSet *selectedServiceIndexes = [self.serviceSelectedFlags
                                              indexesOfObjectsPassingTest:^BOOL(NSNumber *flag, NSUInteger idx, BOOL *stop) {
                                                  return [flag boolValue];
                                              }];
        NSArray *selectedServices = [self.searchOptions objectsAtIndexes:selectedServiceIndexes];
        for (NSString *service in selectedServices) {
            if ([service isEqualToString:SearchOptionOpenNow]) {
                self.pharmacies = [self.pharmacies bk_select:^BOOL(Pharmacy *pharmacy) {
                    return [pharmacy isOpenAt:[NSDate date]];
                }];
            } else {
                self.pharmacies = [self.pharmacies bk_select:^BOOL(Pharmacy *pharmacy) {
                    return [pharmacy.service containsString:service];
                }];
            }
        }
        
        NSLog(@"Pharamcy search took %.1f seconds", [[NSDate date] timeIntervalSinceDate:startTime]);
    }];
    
    searchOperation.completionBlock = completionBlock;
    
    [self.searchQueue cancelAllOperations];
    [self.searchQueue addOperation:searchOperation];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self toggleSearchOptions];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
