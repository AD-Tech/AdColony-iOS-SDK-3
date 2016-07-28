//
//  FeedCellAd.h
//  AdColonyInstantFeed
//
//  Created by Owain Moss on 2/4/15.
//  Copyright (c) 2015 AdColony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdColony/AdColony.h>

@interface FeedCellAd : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *advertiserLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView  *adContainer;
@property (nonatomic) AdColonyNativeAdView *adView;

- (void)pause;
- (void)resume;
@end
