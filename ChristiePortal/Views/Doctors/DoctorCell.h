//
//  DoctorCell.h
//  ChristiePortal
//
//  Created by Nick Mavlitov on 23/09/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface DoctorCell : BaseTableViewCell

/**
 * Label for the doctor's full name.
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/**
 * Label for the doctor's address.
 */
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

/**
 * View containing doctor's photo.
 */
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
