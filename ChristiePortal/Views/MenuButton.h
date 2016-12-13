//
//  MenuButton.h
//  ChristiePortal
//
//  Created by Sergey on 05/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIButton

@property (nonatomic, readonly, getter=isToggled) BOOL toggled;

- (void)toggleAnimated:(BOOL)animated;

@end
