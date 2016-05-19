/**
 *  AdColonyAppOptions.h
 *  AdColonyAppOptions
 *
 *  Created by Owain Moss on 4/7/16.
 */

#import "AdColonyOptions.h"

#import <Foundation/Foundation.h>

@class AdColonyUserMetadata;

NS_ASSUME_NONNULL_BEGIN

/**
 @discussion AdColonyAppOptions objects are used to set configurable aspects of SDK state and behavior, such as a custom user identifier.
 The common usage scenario is to instantiate and configure one of these objects and then pass it to `[AdColony configureWithAppID:zoneIDs:options:completion:]`.
 You can use one of the constants below to configure a specific option.
 Note that you can also reset the current options object the SDK is using by passing an updated object to `setAppOptions:`.
 @see [AdColony setAppOptions:]
 */
@interface AdColonyAppOptions : AdColonyOptions
@end

#pragma mark - AdColony App Option Keys

/**
 Enabled by default.
 Set before calling `configureWithAppID:zoneIDs:options:completion:` with a corresponding value of `@(NO)` to disable AdColony logging.
 */
FOUNDATION_EXPORT NSString* const ADC_OPTION_DISABLE_LOGGING;

/**
 Set a custom identifier for the current user.
 Corresponding value must be 128 characters or less.
 */
FOUNDATION_EXPORT NSString* const ADC_OPTION_USER_ID;

NS_ASSUME_NONNULL_END
