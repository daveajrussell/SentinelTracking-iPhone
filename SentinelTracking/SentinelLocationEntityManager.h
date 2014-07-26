//
//  SentinelLocationEntityManager.h
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SentinelAppDelegate.h"
#import "SentinelSessionEntityManager.h"
#import "SentinelServiceHelper.h"

@class SentinelEntityManager;
@class SentinelServiceHelper;

@interface SentinelLocationEntityManager : NSObject

@property (nonatomic) NSUUID *oUserIdentification;
@property (nonatomic) int iSessionID;
@property (nonatomic) long lTimestamp;
@property (nonatomic) float dLatitude;
@property (nonatomic) float dLongitude;
@property (nonatomic) float dSpeed;
@property (nonatomic) int iOrientation;

@property (nonatomic) SentinelSessionEntityManager *entityManager;
@property (nonatomic) SentinelAppDelegate *appDelegate;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSEntityDescription *entityDescription;
@property (nonatomic) NSFetchRequest *fetchRequest;

-(id)init;
-(void)addData:(CLLocation *)location;
-(int)getDataCount;
-(NSData *)getDataJson;
-(void)deleteData;

@end
