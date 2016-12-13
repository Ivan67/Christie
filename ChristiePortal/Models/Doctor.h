//
//  Doctor.h
//  ChristiePortal
//
//  Created by Sergey on 23/09/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Doctor : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *type;

- (instancetype)initWithName:(NSString *)name address:(NSString *)address type:(NSString *)type;

@end
