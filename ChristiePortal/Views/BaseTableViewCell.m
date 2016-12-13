//
//  BaseTableViewCell.m
//  ChristiePortal
//
//  Created by Sergey on 15/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

+ (NSString *)nibName {
    return NSStringFromClass([self class]);
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
