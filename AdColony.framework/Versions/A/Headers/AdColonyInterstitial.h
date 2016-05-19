/**
 *  AdColonyInterstitial.h
 *  AdColonyInterstitial
 *
 *  Created by Owain Moss on 3/10/15.
 */

#import <Foundation/Foundation.h>

@class UIViewController;

#pragma mark - Constants

/**
 Enum for in-app purchase (IAP) engagement types
 */
typedef NS_ENUM(NSUInteger, ADCOLONY_IAP_ENGAGEMENT) {
    
    /** IAPP was not enabled for the associated ad object. */
    ADCOLONY_IAP_ENGAGEMENT_NONE = 0,
    
    /** IAPP was enabled for the ad; however, there was no user engagement. */
    ADCOLONY_IAP_ENGAGEMENT_AUTOMATIC,
    
    /** IAPP was enabled for the ad, and the user engaged via a dynamic end card (DEC). */
    ADCOLONY_IAP_ENGAGEMENT_END_CARD,
    
    /** IAPP was enabled for the ad, and the user engaged via an in-vdeo engagement (Overlay). */
    ADCOLONY_IAP_ENGAGEMENT_OVERLAY
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AdColonyInterstitial Interface

@interface AdColonyInterstitial : NSObject

/** @name Properties */

/**
 @abstract The unique zone identifier string from which the interstitial was requested.
 @discussion AdColony zone IDs can be created at the [Control Panel](http://clients.adcolony.com).
 @param zoneID The zone identifier string.
 */
@property (nonatomic, readonly) NSString *zoneID;

/**
 @abstract A BOOL indicating whether or not the interstitial has been played or if it has met its expiration time.
 @discussion AdColony interstitials become expired as soon as the ad launches or just before they have met their expiration time.
 @param expired Whether or not the ad has expired.
 */
@property (nonatomic, readonly) BOOL expired;

/**
 @abstract A BOOL indicating whether or not the interstitial has audio enabled.
 @discussion Leverage this property to determine if the application's audio should be paused while the ad is playing.
 @param audioEnabled Whether or not the ad has audio.
 */
@property (nonatomic, readonly) BOOL audioEnabled;


/** @name Ad Event Handlers */

/**
 @abstract Sets the block of code to be executed when the interstitial is displayed to the user.
 @discussion Note that the associated code block will be dispatched on the main thread.
 @param open The block of code to be executed.
 */
-(void)setOpen:(nullable void (^)(void))open;

/**
 @abstract Sets the block of code to be executed when the interstitial is removed from the view hierarchy.
 @discussion Note that the associated code block will be dispatched on the main thread.
 @param close The block of code to be executed.
 */
-(void)setClose:(nullable void (^)(void))close;

/**
 @abstract Sets the block of code to be executed when the interstitial begins playing audio.
 @discussion Note that the associated code block will be dispatched on the main thread.
 @param close The block of code to be executed.
 */
-(void)setAudioStart:(nullable void (^)(void))audioStart;

/**
 @abstract Sets the block of code to be executed when the interstitial stops playing audio.
 @discussion Note that the associated code block will be dispatched on the main thread.
 @param close The block of code to be executed.
 */
-(void)setAudioStop:(nullable void (^)(void))audioStop;

/**
 @abstract Sets the block of code to be executed 5 seconds before an interstitial expires and is no longer valid for playback.
 @discussion Note that the associated code block will be dispatched on the main thread.
 @param expire The block of code to be executed.
 */
-(void)setExpire:(nullable void (^)(void))expire;


/** @name Ad Playback */

/**
 @abstract Triggers a fullscreen ad experience.
 @param viewController The view controller on which the interstitial will display itself.
 @return Whether the ad was able to start playback.
 */
- (BOOL)showWithPresentingViewController:(UIViewController *)viewController;

/**
 @abstract Cancels the interstitial and returns control back to the application.
 */
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
