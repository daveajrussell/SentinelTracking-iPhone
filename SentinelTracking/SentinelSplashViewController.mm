//
//  SentinelSplashViewController.m
//  SentinelTracking
//
//  Created by David Russell on 24/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelSplashViewController.h"

@interface SentinelSplashViewController ()

@end

@implementation SentinelSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if(_entityManager == nil)
        _entityManager = [[SentinelSessionEntityManager alloc] init];
    
    [self checkForExistingSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkForExistingSession
{
    if([_entityManager isExistingSession])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
        SentinelTrackingViewController *trackingViewController = (SentinelTrackingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"trackingController"];
        
        [self presentViewController:trackingViewController animated:YES completion:nil];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
        SentinelAuthenticationViewController *authenticationViewController = (SentinelAuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"authenticationController"];
        
        [self presentViewController:authenticationViewController animated:YES completion:nil];
    }
}

@end
