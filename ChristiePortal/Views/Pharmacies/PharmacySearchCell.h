//
//  PharmacyCell.h
//  ChristiePortal
//
//  Created by michail on 09/09/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "OpenStatusBadge.h"

typedef NS_ENUM(NSInteger, PharmacySearchCellOpenStatus) {
    PharmacySearchCellOpenStatusOpen,
    PharmacySearchCellOpenStatusClosed
};

@interface PharmacySearchCell : BaseTableViewCell

/**
 * Label for the pharmacy name.
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/**
 * Label for the pharmacy addess.
 */
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

/**
 * Displas distance between the location of the pharamcy and the device's current location.
 */
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

/**
 * Contains pharmacy image / photo.
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

/**
 * Indicates the pharmacy is currently open.
 */
@property (weak, nonatomic) IBOutlet OpenStatusBadge *pharmacyOpenStatusBadge;

/**
 * Indicates whether the store and photo are currently open.
 */
@property (weak, nonatomic) IBOutlet OpenStatusBadge *storeAndPhotoOpenStatusBadge;

/**
 * Returns the background color for the specified open status.
 *
 * @return Background color.
 */
+ (UIColor *)colorForOpenStatus:(PharmacySearchCellOpenStatus)status;

@end
