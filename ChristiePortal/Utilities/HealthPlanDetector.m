//
//  HealthPlanDetector.m
//  ChristiePortal
//
//  Created by Sergey on 12/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import "HealthPlanDetector.h"
#import "Polygon.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))
#endif

static const CGPoint InnerTuftsPolygonPoints[] = {
    {42.69454866207692, -73.19503784179688},
    {42.132858175814626, -73.39004516601562},
    {42.11248648904184, -71.72561645507812},
    {41.44066745847661, -71.72286987304688},
    {41.378869509663225, -71.72012329101562},
    {41.292253642159466, -71.75857543945312},
    {41.1724519493126, -71.68167114257812},
    {41.12281462734397, -71.62948608398438},
    {41.16211393939692, -69.91836547851562},
    {41.9615324733056, -69.73983764648438},
    {42.82058801328782, -70.62217712402344},
    {42.81051429991596, -70.94902038574219},
    {42.7520544036665, -71.07948303222656},
    {42.70262285884388, -71.21681213378906},
    {42.64810165693524, -71.27723693847656},
    {42.69454866207692, -73.19503784179688}
};

static const CGPoint OuterTuftsPolygonPoints[] = {
    {42.70262285884388, -73.37287902832031},
    {42.02991418347818, -73.64204406738281},
    {42.0033867213535, -73.61732482910156},
    {41.96970131621059, -71.91169738769531},
    {41.509605687197975, -71.89384460449219},
    {41.36341083816147, -72.02293395996094},
    {41.121780116909356, -71.86500549316406},
    {41.12338431876347, -71.63008479196719},
    {41.164181671865485, -69.92179870605469},
    {41.9625536359481, -69.73915100097656},
    {42.9524020856897, -70.75675964355469},
    {42.93028505122963, -71.04789733886719},
    {42.82864580245114, -71.27723693847656},
    {42.77322729247907, -71.35826110839844},
    {42.81353658623225, -73.33442687988281},
    {42.70262285884388, -73.37287902832031}
};

@implementation HealthPlanDetector

+ (HealthPlan)healthPlanFromLocation:(CLLocation *)location {
    if (location == nil) {
        return HealthPlanUnknown;
    }
    
    CGPoint locationPoint = CGPointMake(location.coordinate.latitude, location.coordinate.longitude);
    
    static Polygon *innerTuftsPolygon;
    if (innerTuftsPolygon == nil) {
        innerTuftsPolygon = [Polygon polygonWithPoints:InnerTuftsPolygonPoints count:ARRAY_SIZE(InnerTuftsPolygonPoints)];
    }
    
    static Polygon *outerTuftsPolygon;
    if (outerTuftsPolygon == nil) {
        outerTuftsPolygon = [Polygon polygonWithPoints:OuterTuftsPolygonPoints count:ARRAY_SIZE(OuterTuftsPolygonPoints)];
    }
    
    if ([innerTuftsPolygon containsPoint:locationPoint]) {
        return HealthPlanTufts;
    } else if ([outerTuftsPolygon containsPoint:locationPoint]) {
        return HealthPlanBoth;
    } else {
        return HealthPlanCigna;
    }
}

@end
