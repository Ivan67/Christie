#import "APIClient.h"
#import "Doctor.h"

static NSString *const APIBaseURLString = @"http://cmapp.rhinoda.ru/web/app_dev.php/api/v1/";

@implementation APIClient

+ (instancetype)sharedClient {
    static APIClient *sharedClient;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });
    
    return sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
        self.requestSerializer = requestSerializer;
        
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/vnd.api+json"]];
        self.responseSerializer = responseSerializer;
    }
    return self;
}

- (NSArray<Doctor *> *)fetchDoctors {
    const NSArray *const doctorsJSON = @[
        @{
            @"name": @"Aller Gist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Allergist"
        },
        @{
            @"name": @"Bob Peanut",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Allergist"
        },
        @{
            @"name": @"Anesthesi Ologist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Anesthesiologist"
        },
        @{
            @"name": @"Emily Hart",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Cardiologist"
        },
        @{
            @"name": @"Diego Suarez",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Cardiologist"
        },
        @{
            @"name": @"Den Tist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Dentist"
        },
        @{
            @"name": @"Peter Pan",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Dentist"
        },
        @{
            @"name": @"Dermat Ologist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Dermatologist"
        },
        @{
            @"name": @"Endo Crinologist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Endocrinologist"
        },
        @{
            @"name": @"Emilio Ologez",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Epidemiologist"
        },
        @{
            @"name": @"Gyn Ecolo",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Gynecologist"
        },
        @{
            @"name": @"Immu Nologist",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Immunologist"
        },
        @{
            @"name": @"Virus Guy",
            @"address": @"375 Flatbush Ave, Brooklyn, NY",
            @"type": @"Infectious Disease Specialist"
        }
    ];
    NSMutableArray *doctors = [[NSMutableArray alloc] init];
    for (NSDictionary *doctorInfo in doctorsJSON) {
        Doctor *doctor = [[Doctor alloc] init];
        doctor.name = doctorInfo[@"name"];
        doctor.address = doctorInfo[@"address"];
        doctor.type = doctorInfo[@"type"];
        [doctors addObject:doctor];
    }
    return doctors;
}

@end
