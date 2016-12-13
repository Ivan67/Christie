//
//  PharmacyCell.m
//  ChristiePortal
//
//  Created by michail on 09/09/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "UIColor+Hex.h"
#import "PharmacySearchCell.h"

@interface PharmacySearchCell ()

// These are defined inside the XIB file as User Defined Runtime Attributes.
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@end

@implementation PharmacySearchCell

+ (UIColor *)colorForOpenStatus:(PharmacySearchCellOpenStatus)status {
    switch (status) {
        case PharmacySearchCellOpenStatusOpen:
            return [UIColor colorWithRGB:0x2b902b];
        case PharmacySearchCellOpenStatusClosed:
            return [UIColor colorWithRGB:0x882a2a];
    }
    return nil;
}

- (void)awakeFromNib {
    static const CGFloat OpenLabelCornerRadius = 5;
    
    self.pharmacyOpenStatusBadge.layer.cornerRadius = OpenLabelCornerRadius;
    self.pharmacyOpenStatusBadge.clipsToBounds = YES;
    
    self.storeAndPhotoOpenStatusBadge.layer.cornerRadius = OpenLabelCornerRadius;
    self.storeAndPhotoOpenStatusBadge.clipsToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.iconImageView.image = self.highlightedImage;
        self.nameLabel.textColor = self.highlightedTextColor;
        self.addressLabel.textColor = self.highlightedTextColor;
        self.distanceLabel.textColor = self.highlightedTextColor;
        self.backgroundColor = self.highlightedBackgroundColor;
    } else {
        self.iconImageView.image = self.normalImage;
        self.nameLabel.textColor = self.normalTextColor;
        self.addressLabel.textColor = self.normalTextColor;
        self.distanceLabel.textColor = self.normalTextColor;
        self.backgroundColor = self.normalBackgroundColor;
    }
}

@end
