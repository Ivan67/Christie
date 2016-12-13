//
//  CVSImporter.m
//  ChristiePortal
//
//  Created by Sergey on 10/18/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <DateTools.h>
#import "CVSDatabaseImporter.h"
#import "CVSDatabaseReader.h"
#import "OpenHoursParser.h"
#import "Pharmacy.h"

@interface CVSDatabaseImporter ()

@property (nonatomic, readonly) CVSDatabaseReader *databaseReader;

@end

@implementation CVSDatabaseImporter

+ (void)updateProgress:(float *)progress
         previousValue:(float *)previousProgress
              newValue:(float)newProgress
                change:(void(^)(float progress))changeHandler {
    static const float ProgressChangeFrequency = 100;
    
    if (newProgress - *previousProgress >= 1 / ProgressChangeFrequency) {
        *previousProgress = newProgress;
        
        if (changeHandler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                changeHandler(newProgress);
            });
        }
    }

    *progress = newProgress;
}

- (instancetype)initWithDatabaseReader:(CVSDatabaseReader *)databaseReader
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
           privateManagedObjectContext:(NSManagedObjectContext *)privateManagedObjectContext {
    if (self = [super init]) {
        _databaseReader = databaseReader;
        _managedObjectContext = managedObjectContext;
        _privateManagedObjectContext = privateManagedObjectContext;
    }
    return self;
}

- (void)importCVSDataUsingProgressBlock:(void(^)(float progress))progressHandler
                             completion:(void(^)())completionHandler {
    [self.privateManagedObjectContext performBlock:^{
        NSDate *startTime = [NSDate date];
        __block NSError *error;

        const float progressPerObject = 1.0f / [self.databaseReader numberOfEntriesInTable:@"store"];
        __block float progress = 0;
        __block float previousProgress = 0;
        
        [self.databaseReader readTable:@"store" usingBlock:^(NSDictionary *store) {
            Pharmacy *pharmacy = [NSEntityDescription insertNewObjectForEntityForName:[Pharmacy entityName] inManagedObjectContext:self.privateManagedObjectContext];
            
            pharmacy.id = store[@"id"];
            pharmacy.address = store[@"address"];
            
            pharmacy.code = store[@"store_code"];
            NSString *numericCode = [pharmacy.code stringByReplacingOccurrencesOfString:@"Store#" withString:@""];
            pharmacy.numericCode = [[[NSNumberFormatter alloc] init] numberFromString:numericCode];
            
            pharmacy.phone = store[@"phone"];
            pharmacy.service = store[@"service"];
            pharmacy.pharmacyHours = store[@"pharmacy_hours"];
            pharmacy.photoHours = store[@"photo_hours"];
            pharmacy.minuteClinicHours = store[@"minuteclinic_hours"];
            pharmacy.url = store[@"url"];
            pharmacy.favorite = @NO;
            pharmacy.latitude = store[@"latitude"];
            pharmacy.longitude = store[@"longitude"];
            
            NSString *timeZoneName = store[@"timezone"];
            pharmacy.timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
            
            DTTimePeriod *workdayHours;
            DTTimePeriod *saturdayHours;
            DTTimePeriod *sundayHours;
            
            [OpenHoursParser parseOpenHours:pharmacy.pharmacyHours
                                 inTimeZone:pharmacy.timeZone
                           workdayOpenHours:&workdayHours
                          saturdayOpenHours:&saturdayHours
                            sundayOpenHours:&sundayHours];
            pharmacy.pharmacyMFHoursOpen = workdayHours.StartDate;
            pharmacy.pharmacyMFHoursClose = workdayHours.EndDate;
            pharmacy.pharmacySatHoursOpen = saturdayHours.StartDate;
            pharmacy.pharmacySatHoursClose = saturdayHours.EndDate;
            pharmacy.pharmacySunHoursOpen = sundayHours.StartDate;
            pharmacy.pharmacySunHoursClose = sundayHours.EndDate;
            
            [OpenHoursParser parseOpenHours:pharmacy.photoHours
                                 inTimeZone:pharmacy.timeZone
                           workdayOpenHours:&workdayHours
                          saturdayOpenHours:&saturdayHours
                            sundayOpenHours:&sundayHours];
            pharmacy.photoMFHoursOpen = workdayHours.StartDate;
            pharmacy.photoMFHoursClose = workdayHours.EndDate;
            pharmacy.photoSatHoursOpen = saturdayHours.StartDate;
            pharmacy.photoSatHoursClose = saturdayHours.EndDate;
            pharmacy.photoSunHoursOpen = sundayHours.StartDate;
            pharmacy.photoSunHoursClose = sundayHours.EndDate;
            
            [OpenHoursParser parseOpenHours:pharmacy.minuteClinicHours
                                 inTimeZone:pharmacy.timeZone
                           workdayOpenHours:&workdayHours
                          saturdayOpenHours:&saturdayHours
                            sundayOpenHours:&sundayHours];
            pharmacy.minuteClinicMFHoursOpen = workdayHours.StartDate;
            pharmacy.minuteClinicMFHoursClose = workdayHours.EndDate;
            pharmacy.minuteClinicSatHoursOpen = saturdayHours.StartDate;
            pharmacy.minuteClinicSatHoursClose = saturdayHours.EndDate;
            pharmacy.minuteClinicSunHoursOpen = sundayHours.StartDate;
            pharmacy.minuteClinicSunHoursClose = sundayHours.EndDate;
            
            [CVSDatabaseImporter updateProgress:&progress previousValue:&previousProgress newValue:progress + progressPerObject change:progressHandler];
        }];
        
        if (![self.privateManagedObjectContext save:&error]) {
            NSLog(@"Failed to save CVS data: %@", error);
            return;
        }
        
        NSLog(@"CVS import took %.1f seconds", [[NSDate date] timeIntervalSinceDate:startTime]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Failed to save CVS data into main context: %@", error);
            } else if (completionHandler != nil) {
                completionHandler();
            }
        });
    }];
}

@end
