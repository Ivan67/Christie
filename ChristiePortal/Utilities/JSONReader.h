//
//  JSONReader.h
//  ChristiePortal
//
//  Created by Sergey on 27/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONReader : NSObject

+ (id)readJSONFromFile:(NSString *)path;

@end
