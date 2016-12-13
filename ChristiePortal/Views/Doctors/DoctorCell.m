//
//  DoctorCell.m
//  ChristiePortal
//
//  Created by Nick Mavlitov on 23/09/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "DoctorCell.h"

@interface DoctorCell ()

// These are defined inside the XIB file as User Defined Runtime Attributes.
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@end

@implementation DoctorCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.photoImageView.image = self.highlightedImage;
        self.nameLabel.textColor = self.highlightedTextColor;
        self.addressLabel.textColor = self.highlightedTextColor;
        self.backgroundColor = self.highlightedBackgroundColor;
    } else {
        self.photoImageView.image = self.normalImage;
        self.nameLabel.textColor = self.normalTextColor;
        self.addressLabel.textColor = self.normalTextColor;
        self.backgroundColor = self.normalBackgroundColor;
    }
}

@end
