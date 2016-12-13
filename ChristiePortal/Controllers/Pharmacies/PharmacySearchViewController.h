#import "FrontViewController.h"

@class Pharmacy;
@class PharmacySearchViewController;

@protocol PharmacySearchViewControllerDelegate <NSObject>

- (void)pharmacySearchViewController:(PharmacySearchViewController *)pharmacySearchViewController
                   didSelectPharmacy:(Pharmacy *)pharmacy;

@end

@interface PharmacySearchViewController : FrontViewController

@property (weak, nonatomic) id<PharmacySearchViewControllerDelegate> delegate;

@end
