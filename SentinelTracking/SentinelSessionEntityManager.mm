//
//  SentinelEntityManager.m
//  SentinelTracking
//
//  Created by David Russell on 22/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelSessionEntityManager.h"

@implementation SentinelSessionEntityManager

- (id)init
{
    self = [super init];
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        _context  = [_appDelegate managedObjectContext];
        
        _entityDescription = [NSEntityDescription entityForName:@"SessionEntity" inManagedObjectContext:_context];
        
        _fetchRequest = [[NSFetchRequest alloc] init];
        [_fetchRequest setEntity:_entityDescription];
     }
    return self;
}

- (BOOL) isExistingSession
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    
    return [sessionData count] > 0;
}

-(void)deleteSessionInformation
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        
        for (NSManagedObject * session in sessionData) {
            [_context deleteObject:session];
        }
        
        [_context save:&error];
    }
    else
        return;
}

- (void)saveSessionInformation:(NSUUID *)userIdentification :(NSNumber *)sessionID
{
    NSError *error;
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SessionEntity" inManagedObjectContext:_context];
    
    NSDate *date = [[NSDate alloc]init];
    
    long shiftStart = [date timeIntervalSince1970];
    long shiftEnding = 32100;
    
    [managedObject setValue: userIdentification forKey:@"strUserIdentification"];
    [managedObject setValue: sessionID forKey:@"iSessionID"];
    [managedObject setValue: [NSNumber numberWithLong:shiftStart ] forKey:@"dSessionBegin"];
    [managedObject setValue: [NSNumber numberWithLong:shiftEnding] forKey:@"dShiftEnd"];
    [managedObject setValue: [NSNumber numberWithBool:NO] forKey:@"blnBreakTaken"];
    
    [_context save:&error];
}
	
- (NSString *)getUserID
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        return [managedObject valueForKey:@"strUserIdentification"];
    }
    else
        return nil;
}

- (NSNumber *)getSessionID
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        return [NSNumber numberWithInt:[[managedObject valueForKey:@"iSessionID"] integerValue]];
    }
    else
        return 0;
}

- (NSNumber *)getSessionBegin
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        return [NSNumber numberWithLong:[[managedObject valueForKey:@"dSessionBegin"] longValue]];
    }
    else
        return 0;
}

- (NSNumber *)getShiftEnding
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        return [NSNumber numberWithLong:[[managedObject valueForKey:@"dShiftEnd"] longValue]];
    }
    else
        return 0;
}

- (BOOL)getBreakTaken
{
    NSError *error;
    NSArray *sessionData = [_context executeFetchRequest:_fetchRequest error:&error];
    NSManagedObject *managedObject = nil;
    
    if([sessionData count] > 0)
    {
        managedObject = sessionData[0];
        return [[managedObject valueForKey:@"blnBreakTaken"] boolValue];
    }
    else
        return false;
}

- (void)setBreakTaken
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"SessionEntity" inManagedObjectContext:_context]];

    NSArray *results = [_context executeFetchRequest:request error:&error];

    NSManagedObject *managedObject = results[0];
    
    [managedObject setValue: [NSNumber numberWithBool:YES] forKey:@"blnBreakTaken"];
    
    [_context save:&error];
}

@end
