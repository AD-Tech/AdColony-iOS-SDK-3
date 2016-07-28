//
//  ViewController.m
//  AdColonyInstantFeed
//
//  Copyright (c) 2016 AdColony. All rights reserved.
//

#import "ViewController.h"

#import "FeedCellImage.h"
#import "FeedCellAd.h"

#define kAd             @"ad"
#define kPost           @"post"
#define kAdView         @"adView"
#define kAdZone         @"adZone"
#define kCellType       @"cellType"
#define kPostImage      @"postImage"
#define kPostImageAR    @"aspectRatio"
#define kFeedCellImage  @"FeedCellImage"
#define kFeedCellAd     @"FeedCellAd"
#define kAdColonyAppID  @"app2086517932ad4b608a"
#define kAdColonyZoneID @"vz7c0765ee52af4d67b9"

#define kAdQueueLimit 2

#define kAdViewCellIndex  4
#define kAdViewCellHeight 277.0f

@interface ViewController ()
{
    BOOL _active;
    
    NSMutableArray *_posts;
    NSMutableArray *_ads;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@end


@implementation ViewController

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Configure AdColony once
    [AdColony configureWithAppID:kAdColonyAppID zoneIDs:@[kAdColonyZoneID] options:nil completion:^(NSArray<AdColonyZone *> * zones) { [self requestAd]; }];
    
    //Hardcoded data source for our feed
    _posts = [@[@{kCellType : kPost, kPostImage : @"Taco-Bell", kPostImageAR : @3.2f},
                @{kCellType : kPost, kPostImage : @"Pacific",   kPostImageAR : @1.78f},
                @{kCellType : kPost, kPostImage : @"MLB",       kPostImageAR : @1.45f},
                @{kCellType : kPost, kPostImage : @"MTV",       kPostImageAR : @1.68f},
                @{kCellType : kPost, kPostImage : @"Fallon",    kPostImageAR : @1.33f},
                @{kCellType : kPost, kPostImage : @"Cashmore",  kPostImageAR : @1.68f},
                @{kCellType : kPost, kPostImage : @"Pugs",      kPostImageAR : @1.41f},
                @{kCellType : kPost, kPostImage : @"Jobs",      kPostImageAR : @1.78f}] mutableCopy];
    
    //Cached ad source
    _ads = [@[] mutableCopy];
    
    //Register our nibs
    [_tableView registerNib:[UINib nibWithNibName:kFeedCellImage bundle:nil] forCellReuseIdentifier:kFeedCellImage];
    [_tableView registerNib:[UINib nibWithNibName:kFeedCellAd bundle:nil] forCellReuseIdentifier:kFeedCellAd];
    
    //Hide the table view until we have at least one ready ad
    _tableView.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Requesting Ads

- (void)requestAd {
    [AdColony requestNativeAdViewInZone:kAdColonyZoneID size:CGSizeMake(300, 169) options:nil viewController:self
        success:^(AdColonyNativeAdView* _Nonnull ad) {
            NSLog(@"AdColony returned a valid native ad view for zone: %@", ad.zoneID);
            
            //Referencing the ad object from within one of its block-based handlers will cause a retain cycle
            __weak AdColonyNativeAdView* weakAd = ad;
            
            //Native video start handler
            ad.start = ^{
                NSLog(@"AdColonyNativeAdView has started");
            };
            
            //Native video finish handler
            ad.finish = ^{
                NSLog(@"AdColonyNativeAdView finished");
                
                //If we have no more native ads ready, just leave the finished one in the feed
                if ([_ads count] == 0) {
                    return;
                }
                
                //If the native ad has been expanded to fullscreen, use the close handler instead
                if (weakAd.opened) {
                    return;
                }
                
                //Try to get an ad that's ready to be viewed and then try to insert it into our feed
                //*** NOTE: Replacing finished ads with new ones will increase publisher revenue
                [self replaceCurrentAd:weakAd];
            };
            
            //Native video open handler
            ad.open = ^{
                NSLog(@"AdColonyNativeAdView has opened");
            };
            
            //Native ad close handler
            ad.close = ^{
                NSLog(@"AdColonyNativeAdView has closed");
            };
            
            //Try to insert the new ad view into our feed
            //If it is already full, queue the new ad for later use
            if (![self updateFeedWithAdView:ad]) {
                NSLog(@"Feed is full of ads right now. Queuing ad for later use");
                [_ads addObject:ad];
            }
            
            //Unhide the table view if this handler indicates at least one ad is ready
            if (!_active) {
                [_spinner stopAnimating];
                _loadingLabel.hidden = YES;
                _tableView.hidden = NO;
                _active = YES;
            }
            
            //Try to get a new ad
            if ([_ads count] <= kAdQueueLimit) {
                [self requestAd];
            }
        }
        failure:^(AdColonyAdRequestError* _Nonnull error) {
            NSLog(@"AdColony returned an error: %@ with suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
            [self requestAd];
        }
     ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellConfig = _posts[indexPath.row];
    NSString *cellType = cellConfig[kCellType];
    
    //There are only two cases to consider here:
    // 1. The cell cannot be an ad
    // 2. The cell is an ad and we have an AdColonyNativeAdView
    if ([cellType isEqualToString:kPost]) {
        return [self createStandardCell:indexPath]; //The cell is just a regular post, so return a standard FeedCell
    } else {
        AdColonyNativeAdView *adView = (AdColonyNativeAdView *)cellConfig[kAdView]; //The cell is an ad, and we have an ad view already
        return [self createCellWithAdView:adView indexPath:indexPath]; //Return a FeedCellAd object
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellConfig = _posts[indexPath.row];
    NSString *cellType = cellConfig[kCellType];
    
    //There are only two cases to consider here:
    // 1. The cell cannot be an ad
    // 2. The cell is an ad and we have an AdColonyNativeAdView
    if ([cellType isEqualToString:kPost]) {
        return [self getImageCellHeight:cellConfig]; //The cell is just a regular post, so return the height for a standard FeedCell
    } else {
        return kAdViewCellHeight; //The cell should be an ad view, so return the height for a FeedCellAd object
    }
}

#pragma mark - Feed Cell Creation

- (FeedCellAd *)createCellWithAdView:(AdColonyNativeAdView *)adView indexPath:(NSIndexPath *)indexPath {
    FeedCellAd *adCell = [_tableView dequeueReusableCellWithIdentifier:kFeedCellAd forIndexPath:indexPath];
    
    //Configure the cell's view elements using the properties of the AdColonyNativeAdView
    adCell.advertiserLabel.text = adView.advertiserName;
    adCell.iconView.image  = adView.advertiserIcon;
    adCell.titleLabel.text = adView.adTitle;
    
    //Size the native ad view appropriately
    CGFloat videoWidth  = adCell.adContainer.frame.size.width;
    CGFloat videoHeight = adCell.adContainer.frame.size.height;
    [adView setFrame:CGRectMake(0, 0, videoWidth, videoHeight)];
    
    //Add the video view to the cell
    adCell.adView = adView;
    
    return adCell;
}

- (FeedCellImage *)createStandardCell:(NSIndexPath *)indexPath {
    //Create a standard cell with an image
    NSDictionary *cellConfig = _posts[indexPath.row];
    FeedCellImage *cell = [_tableView dequeueReusableCellWithIdentifier:kFeedCellImage forIndexPath:indexPath];
    cell.background.image  = [UIImage imageNamed:cellConfig[kPostImage]];
    
    return cell;
}

- (CGFloat)getImageCellHeight:(NSDictionary *)cellConfig {
    CGFloat aspectRatio = [cellConfig[kPostImageAR] floatValue];
    CGFloat tableWidth  = _tableView.frame.size.width;
    return tableWidth / aspectRatio;
}

#pragma mark - Updating Feed and Data Source

- (void)replaceCurrentAd:(AdColonyNativeAdView *)currentAd {
    //Try to insert the next ad into our feed
    AdColonyNativeAdView* newAd = _ads[0];
    [self updateFeedWithAdView:newAd];
    
    //Update the queue of waiting ads
    [_ads removeObjectAtIndex:0];
    
    //Destroy the current ad to free up resources
    [currentAd removeFromSuperview];
    [currentAd destroy];
}

- (BOOL)updateFeedWithAdView:(AdColonyNativeAdView *)adView  {
    NSDictionary *cellConfig = _posts[kAdViewCellIndex];
    NSString *cellType = cellConfig[kCellType];
    
    //We want to insert an ad view in the 5th position of the feed if possible
    //If the cell at that position is currently an image, insert an ad view at that index
    if (![cellType isEqualToString:kAd]) {
        [self updateDataSourceWithAdView:adView atIndex:kAdViewCellIndex];
        return YES;
    }
    
    //If the current ad view is finished, replace it with the new one
    //*** NOTE: Replacing finished ads with new ones will increase publisher revenue
    AdColonyNativeAdView *currentAd = cellConfig[kAdView];
    if (currentAd && currentAd.finished) {
        [_posts removeObjectAtIndex:kAdViewCellIndex];
        [self updateDataSourceWithAdView:adView atIndex:kAdViewCellIndex];
        return YES;
    }
    
    return NO;
}

- (void)updateDataSourceWithAdView:(AdColonyNativeAdView *)adView atIndex:(NSUInteger)index {
    //Update our data source with the new ad view and reload the table view
    [_posts insertObject:@{kCellType : kAd, kAdView : adView} atIndex:index];
    [_tableView reloadData];
}

- (void)removeCurrentAdViewFromDataSource {
    //Remove the old ad view from our data source
    NSDictionary *cellConfig = _posts[kAdViewCellIndex];
    AdColonyNativeAdView *currentAd = cellConfig[kAdView];
    if (currentAd) {
        [_posts removeObjectAtIndex:kAdViewCellIndex];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Resume the ad if our table view is going to display it
    if ([cell isKindOfClass:[FeedCellAd class]]) {
        FeedCellAd* adCell = (FeedCellAd*)cell;
        NSLog(@"Resuming ad view");
        [adCell resume];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Pause the ad if our table view has finished displaying it
    if ([cell isKindOfClass:[FeedCellAd class]]) {
        FeedCellAd* adCell = (FeedCellAd*)cell;
        NSLog(@"Pausing ad view");
        [adCell pause];
    }
}
@end
