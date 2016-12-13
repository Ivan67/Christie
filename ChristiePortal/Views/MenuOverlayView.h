//
//  MenuOverlayView.h
//  ChristiePortal
//
//  Created by Sergey on 12/9/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuOverlayView : UIView

@property (nonatomic, readonly, getter=isToggled) BOOL toggled;

- (void)toggleAnimated:(BOOL)animated;

@end
