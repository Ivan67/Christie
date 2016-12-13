//
//  BaseTableViewCell.h
//  ChristiePortal
//
//  Created by Sergey on 15/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

/**
 * Returns the name of the nib (XIB) file.
 *
 * @return Nib name.
 */
+ (NSString *)nibName;

/**
 * Returns the cell reuse identifier.
 *
 * @return The reuse identifier.
 */
+ (NSString *)reuseIdentifier;

@end
