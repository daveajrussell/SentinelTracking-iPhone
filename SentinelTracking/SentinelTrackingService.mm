//
//  SentinelTrackingService.m
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelTrackingService.h"

@implementation SentinelTrackingService

-(id)init
{
    self = [super init];
    
    if(self)
    {
        if(_locationEntityManager == nil)
            _locationEntityManager = [[SentinelLocationEntityManager alloc] init];
        
        _ServiceURL = @"http://webservices.daveajrussell.com/Services/LocationService.svc";
    }
    
    return self;
}

-(void)performHistoricalServicePost
{
    int dataCount = [_locationEntityManager getDataCount];
    
    if(dataCount == 1)
        [self postHistoricalLocationDataToService:_locationEntityManager.getDataJson];
    else if(dataCount > 1)
        [self postHistoricalLocationDataSetToService:_locationEntityManager.getDataJson];
    else
        return;
}

-(void)performLocationServicePost:(CLLocation *)location
{
    [_locationEntityManager addData:location];
    
    int dataCount = [_locationEntityManager getDataCount];
    
    if(dataCount == 1)
        [self postLocationDataToService:_locationEntityManager.getDataJson];
    else if(dataCount > 1)
        [self postLocationDataSetToService:_locationEntityManager.getDataJson];
    else
        return;
}

-(void)postLocationDataToService:(NSData *)locationJson
{
    NSLog(@"to /PostGeospatialData");
    
    serviceURL = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat:@"%@/%@",_ServiceURL, @"PostGeospatialData"]];
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:locationJson];
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    NSMutableURLRequest *serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
}

-(void)postLocationDataSetToService:(NSData *)locationJson
{
    NSLog(@"to /PostBufferedGeospatialDataSet");
    
    serviceURL = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat:@"%@/%@",_ServiceURL, @"PostBufferedGeospatialDataSet"]];
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:locationJson];
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    NSMutableURLRequest *serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
}

-(void)postHistoricalLocationDataToService:(NSData *)locationJson
{
    NSLog(@"to /PostHistoricalData");
    
    serviceURL = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat:@"%@/%@",_ServiceURL, @"PostHistoricalData"]];
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:locationJson];
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    NSMutableURLRequest *serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
    
    [_locationEntityManager deleteData];
}

-(void)postHistoricalLocationDataSetToService:(NSData *)locationJson
{
    NSLog(@"to /PostBufferedHistoricalData");
    
    serviceURL = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat:@"%@/%@",_ServiceURL, @"PostBufferedHistoricalData"]];
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:locationJson];
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    NSMutableURLRequest *serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
    
    [_locationEntityManager deleteData];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    NSLog(@"Response: %d", [httpResponse statusCode]);
    
    if(200 == [httpResponse statusCode])
    {
        [_locationEntityManager deleteData];
    }
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *) connection
{
    serviceConnection = nil;
    serviceResponse = nil;
    serviceURL = nil;
}

- (void)connection:(NSURLConnection *) connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

@end
