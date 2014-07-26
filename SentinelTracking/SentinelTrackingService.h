//
//  SentinelTrackingService.h
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SentinelLocationEntityManager.h"

@class SentinelEntityManager;

@interface SentinelTrackingService : NSObject
{
    NSMutableData *serviceResponse;
    NSURL *serviceURL;
    NSURLConnection *serviceConnection;
}

@property (nonatomic) SentinelLocationEntityManager *locationEntityManager;

@property (strong, nonatomic) NSString *ServiceURL;

-(void)performHistoricalServicePost;
-(void)performLocationServicePost:(CLLocation *)location;

-(void)postLocationDataToService:(NSData *)locationJson;
-(void)postLocationDataSetToService:(NSData *)locationJson;

-(void)postHistoricalLocationDataToService:(NSData *)locationJson;
-(void)postHistoricalLocationDataSetToService:(NSData *)locationJson;

@end
