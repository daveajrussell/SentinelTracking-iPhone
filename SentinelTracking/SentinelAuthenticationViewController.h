//
//  SentinelAuthenticationViewController.h
//  SentinelTracking
//
//  Created by David Russell on 24/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SentinelAppDelegate.h"
#import "SentinelServiceHelper.h"
#import "SentinelSessionEntityManager.h"
#import "SentinelTrackingService.h"
#import "SentinelTrackingViewController.h"

@class SentinelSessionEntityManager;
@class SentinelTrackingService;

@interface SentinelAuthenticationViewController : UIViewController
{
    NSMutableData *serviceResponse;
    NSURL *serviceURL;
    NSURLConnection *serviceConnection;
}

@property (nonatomic) SentinelTrackingService *trackingService;
@property (nonatomic) SentinelSessionEntityManager *entityManager;

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indProgress;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIScrollView *loginView;

@property (nonatomic) NSString *strUsername;
@property (nonatomic) NSString *strPassword;
@property (nonatomic) NSString *strUserIdentification;
@property (nonatomic) NSNumber *iSessionID;

- (void)saveSessionInformation: (NSUUID *) userIdentification: (NSNumber *) sessionID;
- (void)authenticate:(NSString *) strUsername: (NSString *) strPassword;
- (void)performLogin;

- (IBAction)btnLoginTapped:(id)sender;

@end
