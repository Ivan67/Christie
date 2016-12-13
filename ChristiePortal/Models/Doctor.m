//
//  Doctor.m
//  ChristiePortal
//
//  Created by Sergey on 23/09/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "Doctor.h"

@implementation Doctor

- (instancetype)initWithName:(NSString *)name address:(NSString *)address type:(NSString *)type {
    if (self = [super init]) {
        _name = name;
        _address = address;
        _type = type;
    }
    return self;
}

@end
