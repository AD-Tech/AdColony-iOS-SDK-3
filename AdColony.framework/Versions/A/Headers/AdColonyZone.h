/**
 *  AdColonyZone.h
 *  AdColonyZone
 *
 *  Created by Owain Moss on 3/10/15.
 */

#import <Foundation/Foundation.h>

/**
 * Zone types
 */
typedef NS_ENUM(NSUInteger, ADCOLONY_ZONE_TYPE) {
    
    /** Interstitial zone type */
    ADCOLONY_ZONE_TYPE_INTERSTITIAL = 0,
    
    /** Banner zone type */
    ADCOLONY_ZONE_TYPE_BANNER,
    
    /** Native zone type */
    ADCOLONY_ZONE_TYPE_NATIVE
};

NS_ASSUME_NONNULL_BEGIN

/**
 AdColonyZone objects aggregate informative data about a unique AdColony zone such as its unique identifier, its ADCOLONY_ZONE_TYPE, etc.
 AdColonyZones also provide a block-based handler for zone-level reward events.
 Note that you should never instantiate one of these objects directly. You only need to use them when they are passed to you.
 */
@interface AdColonyZone : NSObject

/** @name Standard Zone Properties */

/**
 @abstract The given zone's unique string identifier.
 @discussion AdColony zone IDs can be created at the [Control Panel](http://clients.adcolony.com).
 @param identifier A globally unique NSString identifying the zone.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract The zone type - interstitial, banner, or native.
 @discussion You can set the type for your zones at the [Control Panel](http://clients.adcolony.com).
 @param identifier An ADCOLONY_ZONE_TYPE indicating what type of ads the given zone supports.
 @see ADCOLONY_ZONE_TYPE
 */
@property (nonatomic, readonly) ADCOLONY_ZONE_TYPE type;

/**
 @abstract Flag indicating whether or not the zone is enabled.
 @discussion Sending invalid zone id strings to `[AdColony configureWithAppID:zoneIDs:options:completion:]` will cause this value to be `NO`.
 @param enabled Whether or not the zone was configured with a valid zone id.
 */
@property (nonatomic, readonly) BOOL enabled;


/** @name Rewards */

/**
 @abstract Flag indicating whether or not the zone is configured for rewards.
 @discussion You can configure rewards in your zones at the [Control Panel](http://clients.adcolony.com).
 Sending invalid zone id strings to `[AdColony configureWithAppID:zoneIDs:options:completion:]` will cause this value to be `NO`.
 @param rewarded Whether or not the zone id configured for rewards.
 */
@property (nonatomic, readonly) BOOL rewarded;

/**
 @abstract The number of completed ad views required to receive a reward for the given zone.
 @discussion This value will be 0 if the given zone is not configured for rewards.
 @param viewsPerReward An NSUInteger denoting the number of ad views required to receive a reward.
 */
@property (nonatomic, readonly) NSUInteger viewsPerReward;

/**
 @abstract The number of ads that must be watched before a reward is given.
 @discussion This value will be 0 if the given zone is not configured for rewards.
 @param viewsUntilReward An NSUInteger denoting the number of ads that must be watched before a reward is given.
 */
@property (nonatomic, readonly) NSUInteger viewsUntilReward;

/**
 @abstract The reward amount for each completed rewarded ad view.
 @discussion This value will be 0 if the given zone is not configured for rewards.
 @param rewardAmount An NSUInteger denoting the reward amount for each rewarded ad.
 */
@property (nonatomic, readonly) NSUInteger rewardAmount;

/**
 @abstract The singular form of the reward name based on the reward amount.
 @discussion This value will be an empty string if the given zone is not configured for rewards.
 @param rewardName An NSString representing the singular form of the reward name based on the reward amount.
 */
@property (nonatomic, readonly) NSString *rewardName;


/** @name Handling Rewards */

/**
 @abstract Sets a block-based reward handler for your zone.
 @discussion Based on the success parameter, client-side reward implementations should consider incrementing the user's currency balance in this method.
 Server-side reward implementations, however, should consider the success parameter and then contact the game server to determine the current total balance for the virtual currency.
 Note that the associated block of code will be dispatched on the main thread.
 @param reward The block of code to be executed after a rewarded ad has been shown.
 */
-(void)setReward:(nullable void (^)(BOOL success, NSString* name, int amount))reward;
@end

NS_ASSUME_NONNULL_END
