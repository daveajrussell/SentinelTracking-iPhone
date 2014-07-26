//
//  SentinelBreakViewController.m
//  SentinelTracking
//
//  Created by David Russell on 25/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelBreakViewController.h"

@interface SentinelBreakViewController ()

@end

@implementation SentinelBreakViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(_entityManager == nil)
        _entityManager = [[SentinelSessionEntityManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    if([self canUserGoOnBreak])
        [self setBreak];
    else
    {
        if(self.isViewLoaded)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message: @"You may not begin your break yet" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            
            [alert show];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
            SentinelTrackingViewController *trackingController = (SentinelTrackingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"trackingController"];
            
            [self presentViewController:trackingController animated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setBreak
{
    _endDate = [NSDate dateWithTimeIntervalSinceNow:10];
    _fiveMinuteEndDate = [NSDate dateWithTimeIntervalSinceNow:5];
    [_entityManager setBreakTaken];
    [_indProgress stopAnimating];
    [self initTimer];
    [self initLocalNotification];
    [_lblTimer setHidden:NO];
}

- (void)initLocalNotification
{
    _breakEndingNotification = [[UILocalNotification alloc] init];
    [_breakEndingNotification setFireDate:_fiveMinuteEndDate];
    _breakEndingNotification.alertBody = @"Your break is ending in 5 minutes.";
    _breakEndingNotification.alertAction = @"Okay";
    _breakEndingNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:_breakEndingNotification];
    
    _breakEndedNotification = [[UILocalNotification alloc] init];
    [_breakEndedNotification setFireDate:_endDate];
    _breakEndedNotification.alertBody = @"Your break has ended.";
    _breakEndedNotification.alertAction = @"Okay";
    _breakEndedNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:_breakEndedNotification];
}

- (void)initTimer
{
    _breakTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_breakTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateCountdown
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *secondComponent = [calendar components:NSSecondCalendarUnit fromDate:[NSDate date] toDate:_endDate options:nil];
    NSNumber *second = [NSNumber numberWithInt:[secondComponent second]];
    
    if([second integerValue] <= 0)
        [self timerExpired];
    else
        _lblTimer.text = [NSString stringWithFormat:@"%02d:%02d",[second integerValue] / 60, [second integerValue] % 60];
}

- (void)timerExpired
{
    [_breakTimer invalidate];
    [_lblTimer setText:@"00:00"];
    [_lblTimer setTextColor:[UIColor redColor]];
    [_btnClockIn setEnabled:YES];
}

- (void)removeNotifications
{
    if(_breakEndingNotification)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:_breakEndingNotification];
        _breakEndingNotification = nil;
    }
    
    if(_breakEndedNotification)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:_breakEndedNotification];
        _breakEndedNotification = nil;
    }
}

- (BOOL)canUserGoOnBreak
{
    NSDate *date = [[NSDate alloc] init];
    long sessionBegan = [[_entityManager getSessionBegin] longValue];
    long timeNow = [date timeIntervalSince1970];
    long nowAndSessionBeginDifference = timeNow - sessionBegan;
    
    BOOL breakAllowed = nowAndSessionBeginDifference >= 16200;
    BOOL breakTaken = [_entityManager getBreakTaken];
                                            
    return YES;//return !breakTaken && breakAllowed;
}

- (IBAction)btnClockInTapped:(id)sender
{
    [self removeNotifications];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
    SentinelTrackingViewController *trackingController = (SentinelTrackingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"trackingController"];
    
    [self presentViewController:trackingController animated:YES completion:nil];
}

@end
