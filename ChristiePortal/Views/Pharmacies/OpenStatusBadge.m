//
//  PharmacyOpenStatusView.m
//  ChristiePortal
//
//  Created by Sergey on 11/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "OpenStatusBadge.h"

@interface OpenStatusBadge ()

@property (weak, nonatomic) IBOutlet UIView *view;
@property (nonatomic) BOOL observingProperties;

@end

@implementation OpenStatusBadge

- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    if (self.observingProperties) {
        for (NSString *property in [self inspectableProperties]) {
            [self removeObserver:self forKeyPath:property];
        }
        self.observingProperties = NO;
    }
}

- (void)setUp {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    [nib instantiateWithOwner:self options:nil];

    self.view.frame = self.bounds;
    [self addSubview:self.view];
}

- (NSArray<NSString *> *)inspectableProperties {
    return @[
        @"fontName",
        @"fontSize",
        @"openTitle",
        @"openColor",
        @"closedTitle",
        @"closedColor",
        @"open"
    ];
}

- (void)awakeFromNib {
    if (!self.observingProperties) {
        for (NSString *property in [self inspectableProperties]) {
            [self addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
        }
        self.observingProperties = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self updateAppearance];
}

- (void)prepareForInterfaceBuilder {
    if (self.fontSize == 0) {
        self.fontSize = [UIFont systemFontSize];
    }
    
    [self updateAppearance];
}

- (void)updateAppearance {
    self.titleLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
    
    if (self.open) {
        self.titleLabel.backgroundColor = self.openColor;
        self.titleLabel.text = self.openTitle;
    } else {
        self.titleLabel.backgroundColor = self.closedColor;
        self.titleLabel.text = self.closedTitle;
    }
}

@end
