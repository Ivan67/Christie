//
//  SearchViewController.h
//  ChristiePortal
//
//  Created by michail on 09/09/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

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
