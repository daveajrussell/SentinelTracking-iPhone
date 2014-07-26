//
//  SentinelEntityManager.h
//  SentinelTracking
//
//  Created by David Russell on 22/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SentinelAppDelegate.h"

@interface SentinelSessionEntityManager : NSObject

@property (nonatomic) SentinelAppDelegate *appDelegate;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSEntityDescription *entityDescription;
@property (nonatomic) NSFetchRequest *fetchRequest;

-(id)init;
-(NSString *)getUserID;
-(NSNumber *)getSessionID;
-(NSNumber *)getSessionBegin;
-(NSNumber *)getShiftEnding;
-(BOOL)getBreakTaken;
-(void)setBreakTaken;
-(void)deleteSessionInformation;
-(void)saveSessionInformation:(NSUUID *)userIdentification: (NSNumber *)sessionID;
-(BOOL)isExistingSession;

@end
