//
//  SentinelAuthenticationViewController.m
//  SentinelTracking
//
//  Created by David Russell on 24/03/2013.
//  Copyright (c) 2013 David Russell. All rights reserved.
//

#import "SentinelAuthenticationViewController.h"

@interface SentinelAuthenticationViewController ()

@end

@implementation SentinelAuthenticationViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    _entityManager = [[SentinelSessionEntityManager alloc] init];
    _trackingService = [[SentinelTrackingService alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)keyboardDidShow: (NSNotification *) notif
{
    [_loginView setContentOffset:CGPointMake(_loginView.contentOffset.x, _loginView.contentOffset.y + 50) animated:YES];
}

- (void)keyboardDidHide: (NSNotification *) notif
{
    [_loginView setContentOffset:CGPointMake(_loginView.contentOffset.x, _loginView.contentOffset.y - 50) animated:YES];
}

- (IBAction)btnLoginTapped:(id)sender
{
    [_indProgress setHidden:NO];
    [self.view endEditing:YES];
    [self authenticate:_txtUsername.text :_txtPassword.text];
}

-(void)authenticate:(NSString *)strUsername :(NSString *)strPassword
{
    NSError *error;
    
    serviceURL = [[NSURL alloc] initWithString:@"http://webservices.daveajrussell.com/Services/AuthenticationService.svc/Authenticate"];
    
    NSDictionary *postData = [NSDictionary dictionaryWithObjectsAndKeys:strUsername, @"strUsername", strPassword, @"strPassword", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Posting %@ to /Authenticate", postData);
    
    NSMutableData *body = [NSMutableData data];
    [body  appendData:jsonData];
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    NSMutableURLRequest *serviceRequest = [SentinelServiceHelper getServiceRequest:body :contentLength :serviceURL];
    
    serviceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self startImmediately:YES];
}

-(void) saveSessionInformation:(NSUUID *)userIdentification :(NSNumber *)sessionID
{
    [_entityManager saveSessionInformation: userIdentification :sessionID];
}

-(void) performLogin
{
    [_trackingService performHistoricalServicePost];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SentinelTracking" bundle:nil];
    SentinelTrackingViewController *trackingViewController = (SentinelTrackingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"trackingController"];
    
    [self presentViewController:trackingViewController animated:YES completion:nil];
}

#pragma NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    NSLog(@"Response: %d", code);

    if(200 != code)
    {
        [_indProgress setHidden:YES];
        [self.view endEditing:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials" message:@"Please check and try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data
{
    NSError *error;
    [serviceResponse appendData:data];
        
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
    NSNumber *iSessionID = [JSON valueForKey:@"SessionID"];
    NSUUID *strUserIdentification = [JSON valueForKey:@"UserKey"];
    
    [self saveSessionInformation :strUserIdentification :iSessionID];
    
    [self performLogin];
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
