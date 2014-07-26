//
//  SentinelLocationEntityManager.m
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelLocationEntityManager.h"

@implementation SentinelLocationEntityManager

-(id)init
{
    self = [super init];
    
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        _context  = [_appDelegate managedObjectContext];
        
        _entityDescription = [NSEntityDescription entityForName:@"LocationEntity" inManagedObjectContext:_context];
        
        _fetchRequest = [[NSFetchRequest alloc] init];
        [_fetchRequest setEntity:_entityDescription];
        
        _entityManager = [[SentinelSessionEntityManager alloc]init];
    }
    
    return self;
}

-(void)addData:(CLLocation *)location
{
    NSError *error;
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"LocationEntity" inManagedObjectContext:_context];
    
    long long millis = ([location.timestamp timeIntervalSince1970] * 1000);
    
    [managedObject setValue: [NSString stringWithString: _entityManager.getUserID] forKey:@"oUserIdentification"];
    [managedObject setValue: _entityManager.getSessionID forKey:@"iSessionID"];
    [managedObject setValue: [NSNumber numberWithLongLong: millis] forKey:@"lTimeStamp"];
    [managedObject setValue: [NSNumber numberWithDouble: location.coordinate.latitude] forKey:@"dLatitude"];
    [managedObject setValue: [NSNumber numberWithDouble: location.coordinate.longitude] forKey:@"dLongitude"];
    [managedObject setValue: [NSNumber numberWithDouble: location.speed != -1 ? location.speed * 2.23693629 : 0] forKey:@"dSpeed"];
    [managedObject setValue: [NSNumber numberWithInt: [[UIDevice currentDevice] orientation]] forKey:@"iOrientation"];
    
    [_context save:&error];
}

-(int)getDataCount
{
    NSError *error;
    NSArray *locationData = [_context executeFetchRequest:_fetchRequest error:&error];
    
    return [locationData count];
}

-(NSData *)getDataJson
{
    NSError *error;
    NSArray *locationData = [_context executeFetchRequest:_fetchRequest error:&error];
    
    if([locationData count] == 1)
    {
        NSManagedObject *locationObject = locationData[0];
        NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [locationObject valueForKey:@"oUserIdentification"], @"oUserIdentification",
                                  [locationObject valueForKey:@"iSessionID"], @"iSessionID",
                                  [locationObject valueForKey:@"lTimeStamp"], @"lTimeStamp",
                                  [locationObject valueForKey:@"dLatitude"], @"dLatitude",
                                  [locationObject valueForKey:@"dLongitude"], @"dLongitude",
                                  [locationObject valueForKey:@"dSpeed"], @"dSpeed",
                                  [locationObject valueForKey:@"iOrientation"], @"iOrientation",
                                  nil];
        
        NSLog(@"Posting %@", json);
        
        return [NSJSONSerialization dataWithJSONObject:json options:NSJSONReadingAllowFragments error:&error];
    }
    else if ([locationData count] > 1)
    {        
        NSMutableDictionary *jsonArray = [[NSMutableDictionary alloc]init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSManagedObject * locationObject in locationData) {
            NSDictionary *locationJson = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [locationObject valueForKey:@"oUserIdentification"], @"oUserIdentification",
                                      [locationObject valueForKey:@"iSessionID"], @"iSessionID",
                                      [locationObject valueForKey:@"lTimeStamp"], @"lTimeStamp",
                                      [locationObject valueForKey:@"dLatitude"], @"dLatitude",
                                      [locationObject valueForKey:@"dLongitude"], @"dLongitude",
                                      [locationObject valueForKey:@"dSpeed"], @"dSpeed",
                                      [locationObject valueForKey:@"iOrientation"], @"iOrientation",
                                      nil];
            //[jsonArray addEntriesFromDictionary:locationJson];
            [array addObject:locationJson];
        }
        
        [jsonArray setObject:array forKey:@"BufferedData"];
        
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:array, @"BufferedData", nil];
        //NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:jsonArray, @"BufferedData", nil];
        
        NSLog(@"Posting %@", jsonArray);
        
        return [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONReadingAllowFragments error:&error];
    }
    else
        return nil;
}

-(void)deleteData
{
    NSError *error;
    NSArray *locationData = [_context executeFetchRequest:_fetchRequest error:&error];
    
    if([locationData count] > 0)
    {
        for (NSManagedObject * location in locationData)
        {
            [_context deleteObject:location];
        }
        
        [_context save:&error];
    }
    else
        return;
}

@end
