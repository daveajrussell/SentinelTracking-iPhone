//
//  SentinelTrackingViewController.m
//  SentinelTracking
//
//  Created by David Russell on 20/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelTrackingViewController.h"

@interface SentinelTrackingViewController ()

@end

@implementation SentinelTrackingViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];

    _mapView.showsUserLocation = YES;
    
    _trackingService = [[SentinelTrackingService alloc]init];
    _entityManager = [[SentinelSessionEntityManager alloc] init];
    
    if(![_entityManager getBreakTaken])
        [self setNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnScanTapped:(id)sender
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    
    NSMutableSet *readers = [[NSMutableSet alloc ] init];
    
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    
    widController.readers = readers;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay = [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    [self presentViewController:widController animated:YES completion:nil];
}

- (IBAction)btnBreakTapped:(id)sender
{    
    [_locationManager stopUpdatingLocation];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
    SentinelBreakViewController *breakController = (SentinelBreakViewController *)[storyboard instantiateViewControllerWithIdentifier:@"breakLogic"];
    
    [self presentViewController:breakController animated:YES completion:nil];
}

- (IBAction)btnLogoutTapped:(id)sender
{
    long shiftEnding = [[_entityManager getShiftEnding] longValue];
    long shiftBegan = [[_entityManager getSessionBegin] longValue];
    
    shiftEnding += shiftBegan + 300;
    
    NSDate *dateShiftEnding = [[NSDate alloc] initWithTimeIntervalSince1970:shiftEnding];
        
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date] toDate:dateShiftEnding options:nil];
    
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Logout?"];
	[alert setMessage:[NSString stringWithFormat:@"You still have %02d:%02d:%02d of your shift remaining.", hour, minute, second]];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
		[self performLogout];
	else
        return;
}

- (void)performLogout
{
    [_locationManager stopUpdatingLocation];
    
    NSError *error;
    
    serviceURL = [[NSURL alloc] initWithString:@"http://webservices.daveajrussell.com/Services/AuthenticationService.svc/Logout"];
    
    NSNumber *iSessionID = [_entityManager getSessionID];
    NSString *strUserIdentification = [_entityManager getUserID];
    
    NSDictionary *postData = [NSDictionary dictionaryWithObjectsAndKeys: strUserIdentification, @"oUserIdentification", iSessionID, @"iSessionID", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Posting %@ to Logout service", postData);
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:jsonData];
    
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];

    [self removeNotifications];
    [_entityManager deleteSessionInformation];
    [self returnToAuthentication];
}

- (void)returnToAuthentication
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
    SentinelAuthenticationViewController *loginLogicController = (SentinelAuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"authenticationController"];
    
    [self presentViewController:loginLogicController animated:YES completion:nil];
}

- (void)performDelivery
{
    NSError *error;
    NSDate *date = [[NSDate alloc] init];
    
    long long timestampInMillis = ([date timeIntervalSince1970] * 1000);
    
    serviceURL = [[NSURL alloc] initWithString:@"http://webservices.daveajrussell.com/Services/DeliveryService.svc/GeoTagDelivery"];
    
    NSDictionary *postData = [NSDictionary dictionaryWithObjectsAndKeys:
                              _assetKey, @"oAssetKey",
                              [_entityManager getUserID], @"oUserIdentification",
                              timestampInMillis, @"lTimeStamp",
                              _lastLocation.coordinate.latitude, @"dLatitude",
                              _lastLocation.coordinate.longitude, @"dLongitude",
                              nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Posting %@ to GeoTag service", postData);
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:jsonData];
    
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
}

- (void)setNotifications
{    
    _shiftEndingNotification = [[UILocalNotification alloc] init];
    _breakNotification = [[UILocalNotification alloc] init];
    
    [_shiftEndingNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:[[_entityManager getShiftEnding] longValue]]];
    _shiftEndingNotification.alertBody = @"Your shift is ending in 5 minutes.";
    _shiftEndingNotification.alertAction = @"Okay";
    _shiftEndingNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [_breakNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:15900]];
    _breakNotification.alertBody = @"Your break is scheduled to begin in 5 minutes.";
    _breakNotification.alertAction = @"Okay";
    _breakNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:_shiftEndingNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:_breakNotification];
}

- (void)removeNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"Response: %d", code);
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

#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {

    if(nil != result)
    {
        _assetKey = [[NSUUID alloc]initWithUUIDString:result];
        [self performDelivery];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Unsuccessful" message:@"Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    if(_lastLocation == nil)
    {
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100);
        [_mapView setRegion:region animated:YES];
        
        _lastLocation = newLocation;
        [_trackingService performLocationServicePost:_lastLocation];
    }
    else
    {
        NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
        NSTimeInterval lastUpdate = [_lastLocation.timestamp timeIntervalSinceNow];
        double elapsedSinceLastUpdate = abs(howRecent - lastUpdate);

        if(elapsedSinceLastUpdate >= 10)
        {
            MKCoordinateRegion region;
            region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100);
            [_mapView setRegion:region animated:YES];
            
            _lastLocation = newLocation;
            [_trackingService performLocationServicePost:_lastLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting Location" message:errorType delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

@end
