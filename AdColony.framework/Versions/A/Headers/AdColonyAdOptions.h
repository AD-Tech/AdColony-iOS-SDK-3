/**
 *  AdColonyAdOptions.h
 *  AdColonyAdOptions
 *
 *  Created by Owain Moss on 4/7/16.
 */

#import "AdColonyOptions.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 AdColonyAdOptions objects are used to set configurable aspects of an ad request, such as third-party network settings, user metadata, etc.
 */
@interface AdColonyAdOptions : AdColonyOptions
@end

#pragma mark - AdColony Ad Option Keys

/**
 Enable a reward dialog to be displayed immediately before rewarded interstitials begin playback.
 Use a corresponding value of `@(YES)` to enable.
 */
FOUNDATION_EXPORT NSString* const ADC_OPTION_PRE_POPUP;

/**
 Enable a reward dialog to be displayed immediately after rewarded interstitials finish playback.
 Use a corresponding value of `@(YES)` to enable.
 */
FOUNDATION_EXPORT NSString* const ADC_OPTION_POST_POPUP;

NS_ASSUME_NONNULL_END
