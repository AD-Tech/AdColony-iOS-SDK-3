//
//  FeedCellAd.m
//  AdColonyInstantFeed
//
//  Created by Owain Moss on 2/4/15.
//  Copyright (c) 2015 AdColony. All rights reserved.
//

#import "FeedCellAd.h"

@implementation FeedCellAd

#pragma mark - Video View

- (void)setAdView:(AdColonyNativeAdView *)adView {
    [_adContainer addSubview:adView];
    
    _adView = adView;
}

#pragma mark - Pause/Resume

- (void)pause {
    [_adView pause];
}

- (void)resume {
    [_adView resume];
}
@end
