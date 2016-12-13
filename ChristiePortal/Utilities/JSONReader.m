#import "JSONReader.h"

@implementation JSONReader

+ (id)readJSONFromFile:(NSString *)path {
    NSError *error;
    NSString *contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        return nil;
    }
    
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        return nil;
    }
    return JSONObject;
}

@end
