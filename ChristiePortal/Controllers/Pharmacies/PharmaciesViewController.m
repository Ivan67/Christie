#import "DataManager.h"
#import "NavigationController.h"
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

@property (nonatomic) Pharmacy *favoritePharmacy;
@property (nonatomic) Pharmacy *recentPharmacy1;
@property (nonatomic) Pharmacy *recentPharmacy2;

- (IBAction)showSearchView;
- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender;

@end

@implementation PharmaciesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Pharmacies";
    [self setTitle:@"Pharmacies" image:@"menu_pharmacies"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
    
    NSArray<Pharmacy *> *pharmacies = [[DataManager sharedManager] fetchPharmacies];
    NSArray<Pharmacy *> *favoritePharmacies = [pharmacies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"favorite == 1"]];
    self.favoritePharmacy = [favoritePharmacies firstObject];
    
    if (self.favoritePharmacy == nil) {
        self.favoritePharmacyButton.hidden = YES;
        self.noFavoritePharamcyLabel.hidden = NO;
    } else {
        self.favoritePharmacyButton.hidden = NO;
        self.favoritePharmacyName.text = self.favoritePharmacy.displayName;
        self.favoritePharmacyAddress.text = self.favoritePharmacy.address;
        self.noFavoritePharamcyLabel.hidden = YES;
    }
    
    NSArray<Pharmacy *> *everViewedPharmacies = [pharmacies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastViewed != nil"]];
    NSArray<Pharmacy *> *recentPharmacies = [everViewedPharmacies sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:NO]]];
    
    if (recentPharmacies.count == 0) {
        self.recentPharmacy1Button.hidden = YES;
        self.recentPharmacy2Button.hidden = YES;
        self.noRecentPharmaciesLabel.hidden = NO;
    } else {
        self.noRecentPharmaciesLabel.hidden = YES;
        
        self.recentPharmacy1Button.hidden = NO;
        self.recentPharmacy1 = recentPharmacies[0];
        self.recentPharmacy1Name.text = self.recentPharmacy1.displayName;
        self.recentPharmacy1Address.text = self.recentPharmacy1.address;
        
        if (recentPharmacies.count >= 2) {
            self.recentPharmacy2Button.hidden = NO;
            self.recentPharmacy2 = recentPharmacies[1];
            self.recentPharmacy2Name.text = self.recentPharmacy2.displayName;
            self.recentPharmacy2Address.text = self.recentPharmacy2.address;
        } else {
            self.recentPharmacy2Button.hidden = YES;
        }
    }
    
    [self.activityIndicator stopAnimating];
}

- (IBAction)showSearchView {
    PharmacySearchViewController *pharmacySearchViewController = [[PharmacySearchViewController alloc] init];
    pharmacySearchViewController.delegate = self;
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:pharmacySearchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender {
    Pharmacy *pharmacy;
    if (sender.view == self.favoritePharmacyButton) {
        pharmacy = self.favoritePharmacy;
    } else if (sender.view == self.recentPharmacy1Button) {
        pharmacy = self.recentPharmacy1;
    } else if (sender.view == self.recentPharmacy2Button) {
        pharmacy = self.recentPharmacy2;
    }
    if (pharmacy != nil) {
        [self.navigationManager navigateTo:@"/pharmacies/details" withParameters:@{
            @"pharmacy": pharmacy
        }];
    }
}

- (void)pharmacySearchViewController:(PharmacySearchViewController *)pharmacySearchViewController didSelectPharmacy:(Pharmacy *)pharmacy {
    PharmacyDetailsViewController *pharmacyDetailsViewController = [[PharmacyDetailsViewController alloc] init];
    pharmacyDetailsViewController.pharmacy = pharmacy;
    [pharmacySearchViewController.navigationController pushViewController:pharmacyDetailsViewController animated:YES];
}

@end
