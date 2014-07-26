//
//  SentinelTrackingViewController.h
//  SentinelTracking
//
//  Created by David Russell on 20/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import "SentinelAppDelegate.h"
#import "SentinelAuthenticationViewController.h"
#import "SentinelTrackingService.h"
#import "SentinelSessionEntityManager.h"
#import "SentinelBreakViewController.h"

@class SentinelTrackingService;
@class SentinelSessionEntityManager;

@interface SentinelTrackingViewController : UIViewController <CLLocationManagerDelegate, ZXingDelegate>
{
    NSMutableData *serviceResponse;
    NSURL *serviceURL;
    NSMutableURLRequest *serviceRequest;
    NSURLConnection *serviceConnection;
}

@property (nonatomic) SentinelTrackingService *trackingService;
@property (nonatomic) SentinelSessionEntityManager *entityManager;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnLogout;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnScan;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBreak;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) NSUUID *assetKey;

@property (strong, nonatomic) UILocalNotification *shiftEndingNotification;
@property (strong, nonatomic) UILocalNotification *breakNotification;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)performLogout;
- (void)setNotifications;
- (void)removeNotifications;
- (IBAction)btnLogoutTapped:(id)sender;
- (IBAction)btnScanTapped:(id)sender;
- (IBAction)btnBreakTapped:(id)sender;

@end
