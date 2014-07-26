//
//  SentinelServiceHelper.m
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelServiceHelper.h"

@implementation SentinelServiceHelper

+ (NSMutableURLRequest *) getServiceRequest:(NSMutableData *) body:(NSString *) contentLength:(NSURL *) serviceUrl
{
    NSMutableURLRequest *serviceRequest = [[NSMutableURLRequest alloc] init];
    
    [serviceRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [serviceRequest setHTTPShouldHandleCookies:NO];
    [serviceRequest setTimeoutInterval:30];
    [serviceRequest setURL:serviceUrl];
    [serviceRequest setHTTPMethod:@"POST"];
    [serviceRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serviceRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [serviceRequest setHTTPBody:body];
    [serviceRequest setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    return serviceRequest;
}

@end
