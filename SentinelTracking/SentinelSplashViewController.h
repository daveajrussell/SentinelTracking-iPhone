//
//  SentinelSplashViewController.h
//  SentinelTracking
//
//  Created by David Russell on 24/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SentinelAuthenticationViewController.h"
#import "SentinelTrackingViewController.h"

@class SentinelTrackingViewController;
@class SentinelSessionEntityManager;

@interface SentinelSplashViewController : UIViewController

@property (nonatomic) SentinelSessionEntityManager *entityManager;

- (void)checkForExistingSession;

@end
