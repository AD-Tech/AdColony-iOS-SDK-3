/**
 *  AdColony.h
 *  AdColony
 *
 *  Created by Owain Moss on 3/10/15.
 */

#import "AdColonyAdOptions.h"
#import "AdColonyAppOptions.h"
#import "AdColonyZone.h"
#import "AdColonyInterstitial.h"
#import "AdColonyAdRequestError.h"
#import "AdColonyUserMetadata.h"

#import <Foundation/Foundation.h>

#pragma mark - AdColony Interface

NS_ASSUME_NONNULL_BEGIN

/**
 The AdColony interface constists of a set of static methods for interacting with the SDK.
 */
@interface AdColony : NSObject

/** @name Starting AdColony */

/**
 @abstract Configures AdColony specifically for your app; required for usage of the rest of the API.
 @discussion This method returns immediately; any long-running work such as network connections are performed in the background.
 AdColony does not begin preparing ads for display or performing reporting until after it is configured by your app.
 The required appID and zoneIDs parameters for this method can be created and retrieved at the [Control Panel](http://clients.adcolony.com).
 If either of these are `nil`, app will be unable to play ads and AdColony will only provide limited reporting and install tracking functionality.
 @param appID The AdColony app ID for your app.
 @param zoneIDs An array of at least one AdColony zone ID string.
 @param options (optional) Configuration options for your app.
 @param completion (optional) A block of code to be executed upon completion of the configuration operation. Dispatched on main thread.
 @see AdColonyAppOptions
 @see AdColonyZone
 */
+ (void)configureWithAppID:(NSString *)appID zoneIDs:(NSArray<NSString *> *)zoneIDs options:(nullable AdColonyAppOptions *)options completion:(nullable void (^)(NSArray<AdColonyZone *> *zones))completion;


/** @name Requesting Ads */

/**
 @abstract Requests an AdColonyInterstitial.
 @discussion This method returns immediately, before the ad request completes.
 If the request is successful, an AdColonyInterstitial object will be passed to the success block.
 If the request is unsuccessful, the failure block will be called.
 @param zone The AdColony zone identifier string indicating which zone the ad request is for.
 @param options An AdColonyAdOptions object used to set configurable aspects of the ad request.
 @param success A block of code to be executed if the ad request succeeds.
 @param failure (optional) A block of code to be executed if the ad request does not succeed.
 @see AdColonyAdOptions
 @see AdColonyInterstitial
 @see AdColonyAdRequestError
 */
+ (void)requestInterstitialInZone:(NSString *)zoneID options:(nullable AdColonyAdOptions *)options success:(void (^)(AdColonyInterstitial *ad))success failure:(nullable void (^)(AdColonyAdRequestError *error))failure;


/** @name Zone Retrieval */

/**
 @abstract Retrieves an AdColonyZone object.
 @discussion AdColonyZone objects aggregate informative data about unique AdColony zones such as their identifiers, whether or not they are configured for rewards, etc.
 AdColony zone IDs can be created and retrieved at the [Control Panel](http://clients.adcolony.com).
 @param ID The AdColony zone identifier string indicating which zone to return.
 @return An AdColonyZone object. Returns `nil` if an invalid zone ID is passed.
 @see AdColonyZone
 */
+ (nullable AdColonyZone *)zoneForID:(NSString *)zoneID;


/** @name Device Identifiers */

/**
 @abstract Retrieves the device's current advertising identifier.
 The identifier is an alphanumeric string unique to each device, used by systems to facilitate ad serving.
 Note that this method can be called before `configureWithAppID:zoneIDs:options:completion`.
 @return The device's current advertising identifier.
 */
+ (NSString *)getAdvertisingID;
 
/**
 @abstract Retrieves the identifier for the current user if it has been set.
 @discussion This is an arbitrary, application-specific identifier string for the current user.
 To configure this identifier, use the `setOption:withStringValue` method of the AdColonyAppOptions object you pass to `configureWithAppID:zoneIDs:options:completion`.
 Note that if this method is called before `configureWithAppID:zoneIDs:options:completion`, it will return an empty string.
 @return The identifier for the current user.
 */
+ (NSString *)getUserID;


/** @name App Options */

/**
 @abstract Sets the current, global set of AdColonyAppOptions.
 @discussion Note that you must instantiate the options object with at least one AdColony zone identifier string.
 Call the object's option-setting methods to configure other, currently-supported options.
 @param options The AdColonyAppOptions object to be used for configuring global options such as a custom user identifier.
 @see Option Keys
 */
+ (void)setAppOptions:(AdColonyAppOptions *)options;

/**
 @abstract Returns the current, global set of AdColonyAppOptions.
 @discussion Call this method to obtain the current set of app options used to configure SDK behavior.
 If no options object has been set, this method will return `nil`.
 @return The current AdColonyAppOptions object being used by the SDK.
 @see AdColonyAppOptions
 */
+ (nullable AdColonyAppOptions *)getAppOptions;


/** @name SDK Version */

/**
 @abstract Use this method to retrieve a string-based representation of the SDK version.
 @return The current AdColony SDK version string.
 */
+ (NSString*)getSDKVersion;
@end

NS_ASSUME_NONNULL_END
