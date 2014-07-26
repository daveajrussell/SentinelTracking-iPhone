//
//  SentinelBreakViewController.h
//  SentinelTracking
//
//  Created by David Russell on 25/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SentinelTrackingViewController.h"

@class SentinelSessionEntityManager;

@interface SentinelBreakViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblTimer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnClockIn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indProgress;

@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSDate *fiveMinuteEndDate;
@property (nonatomic) NSTimer *breakTimer;
@property (nonatomic) SentinelSessionEntityManager *entityManager;
@property (nonatomic) UILocalNotification *breakEndingNotification;
@property (nonatomic) UILocalNotification *breakEndedNotification;

- (void)setBreak;
- (BOOL)canUserGoOnBreak;
- (IBAction)btnClockInTapped:(id)sender;

@end
