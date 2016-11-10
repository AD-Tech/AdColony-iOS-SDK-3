//
//  ViewController.m
//  AdColonyBasic
//
//  Copyright (c) 2016 AdColony. All rights reserved.
//

#import "ViewController.h"

#import <AdColony/AdColony.h>

#pragma mark - Constants

#define kAdColonyAppID @"appbdee68ae27024084bb334a"
#define kAdColonyZoneID @"vzf8fb4670a60e4a139d01b5"

#pragma mark - ViewController Interface

@interface ViewController ()
{
    AdColonyInterstitial *_ad;
}
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@end


@implementation ViewController

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Configure AdColony as soon as the app starts
    [AdColony configureWithAppID:kAdColonyAppID zoneIDs:@[kAdColonyZoneID] options:nil completion:^(NSArray<AdColonyZone *> * zones) {
        
        //AdColony has finished configuring, so let's request an interstitial ad
        [self requestInterstitial];
        
        //If the application has been inactive for a while, our ad might have expired so let's add a check for a nil ad object
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }];
    
    //Show the user that we are currently loading videos
    [self setLoadingState];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - AdColony

- (void)requestInterstitial {
    //Request an interstitial ad from AdColony
    [AdColony requestInterstitialInZone:kAdColonyZoneID options:nil
     
        //Handler for successful ad requests
        success:^(AdColonyInterstitial *ad) {
            
            //Once the ad has finished, set the loading state and request a new interstitial
            ad.close = ^{
                _ad = nil;
                
                [self setLoadingState];
                [self requestInterstitial];
            };
            
            //Interstitials can expire, so we need to handle that event also
            ad.expire = ^{
                _ad = nil;
                
                [self setLoadingState];
                [self requestInterstitial];
            };
            
            //Store a reference to the returned interstitial object
            _ad = ad;
            
            //Show the user we are ready to play a video
            [self setReadyState];
        }
     
        //Handler for failed ad requests
        failure:^(AdColonyAdRequestError *error) {
            NSLog(@"SAMPLE_APP: Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
        }
     ];
}

- (IBAction)launchInterstitial:(id)sender {
    //Display our ad to the user
    if (!_ad.expired) {
        [_ad showWithPresentingViewController:self];
    }
}

#pragma mark - UI

- (void)setLoadingState {
    _launchButton.hidden = YES;
    _launchButton.alpha = 0.0;
    _loadingLabel.hidden = NO;
    [_spinner startAnimating];
}

-(void)setReadyState {
    _loadingLabel.hidden = YES;
    _launchButton.hidden = NO;
    [_spinner stopAnimating];
    [UIView animateWithDuration:1.0 animations:^{ _launchButton.alpha = 1.; } completion:nil];
}

#pragma mark - Event Handlers

-(void)onBecameActive {
    //If our ad has expired, request a new interstitial
    if (!_ad) {
        [self requestInterstitial];
    }
}
@end
