//
//  SentinelServiceHelper.h
//  SentinelTracking
//
//  Created by David Russell on 23/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SentinelServiceHelper : NSObject

+ (NSMutableURLRequest *) getServiceRequest:(NSMutableData *) body:(NSString *) contentLength:(NSURL *) serviceUrl;

@end
