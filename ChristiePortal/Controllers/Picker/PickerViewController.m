//
//  MapsAppPickerViewController.m
//  ChristiePortal
//
//  Created by Sergey on 11/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "PickerViewController.h"

static const NSInteger CancelButtonTag = 0;

@implementation PickerAction

- (instancetype)initWithTitle:(NSString *)title handler:(PickeActionHandler)handler {
    if (self = [super init]) {
        _title = title;
        _handler = handler;
    }
    return self;
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(PickeActionHandler)handler {
    return [[self alloc] initWithTitle:title handler:handler];
}

@end

@interface PickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

@property (nonatomic) CGRect normalButtonsContainerFrame;
@property (nonatomic) CGRect hiddenButtonsContainerFrame;
@property (nonatomic) CGFloat buttonsAnimationDuration;

@end

@implementation PickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _actions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<UIButton *> *buttons = @[
        self.button1,
        self.button2,
        self.button3,
        self.button4
    ];
    for (NSUInteger i = 0; i < buttons.count; i++) {
        UIButton *button = buttons[i];
        if (i < self.actions.count) {
            [button setTitle:self.actions[i].title forState:UIControlStateNormal];
            button.hidden = NO;
        } else {
            button.hidden = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.normalButtonsContainerFrame = self.buttonsContainerView.frame;
    self.hiddenButtonsContainerFrame = CGRectOffset(self.normalButtonsContainerFrame, 0, self.normalButtonsContainerFrame.size.height);
    
    if (animated) {
        self.buttonsContainerView.frame = self.hiddenButtonsContainerFrame;
        [UIView animateWithDuration:[CATransaction animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.buttonsContainerView.frame = self.normalButtonsContainerFrame;
        } completion:nil];
    }
}

- (void)addAction:(PickerAction *)action {
    NSMutableArray *actions = [_actions mutableCopy];
    [actions addObject:action];
    _actions = actions;
}

- (IBAction)performActionForButton:(UIButton *)button {
    if (button.tag == CancelButtonTag) {
        [self dismiss];
        return;
    }
    
    if (button.tag > 0 && (NSUInteger)button.tag <= self.actions.count) {
        NSUInteger actionIndex = (NSUInteger)button.tag - 1;
        if (self.actions[actionIndex].handler != nil) {
            self.actions[actionIndex].handler();
        }
        [self dismiss];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
