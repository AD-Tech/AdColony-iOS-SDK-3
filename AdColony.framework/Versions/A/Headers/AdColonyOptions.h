/**
 *  AdColonyOptions.h
 *  AdColonyOptions
 *
 *  Created by Owain Moss on 4/7/16.
 */

#import <Foundation/Foundation.h>

@class AdColonyUserMetadata;

NS_ASSUME_NONNULL_BEGIN

/**
 AdColonyOptions is a superclass for all types of AdColonyOptions. 
 Note that AdColonyOptions classes should never be instantiated directly.
 Instead, create one of the subclasses and set options on it using the string-based constants defined in its header file.
 */
@interface AdColonyOptions : NSObject

/** @name Properties */

/**
 @abstract An AdColonyUserMetadata object.
 @discussion Configure and set this property to improve ad targeting.
 @param userMetadata The AdColonyUserMetadata object.
 @see AdColonyUserMetadata
 */
@property (nonatomic) AdColonyUserMetadata* userMetadata;

/** @name Setting Options */

/**
 @abstract Sets a supported option using one of the option key constants.
 @discussion Note that only NSString and NSNumber option values are supported at this time.
 @param option An NSString representing the option.
 @param value An NSString used to configure the option. Strings must be 128 characters or less.
 @return A BOOL indicating whether or not the option was set successfully.
 @see AdColonyAppOptions
 @see AdColonyAdOptions
 */
- (BOOL)setOption:(NSString *)option withStringValue:(NSString *)value;

/**
 @abstract Sets a supported option using one of the option key constants.
 @discussion Note that only NSString and NSNumber option values are supported at this time.
 @param option An NSString representing the option.
 @param value An NSNumber used to configure the option. Strings must be 128 characters or less.
 @return A BOOL indicating whether or not the option was set successfully.
 @see AdColonyAppOptions
 @see AdColonyAdOptions
 */
- (BOOL)setOption:(NSString *)option withNumericValue:(NSNumber *)value;


/** @name Option Retrieval */

/**
 @abstract Returns the string-based option associated with the given key.
 @discussion Call this method using one of the string-based metadata keys in your subclass to get the corresponding value.
 @param key A string-based option key.
 @return The option value associated with the given key. Returns `nil` if the option has not been set.
 @see AdColonyAppOptions
 @see AdColonyAdOptions
 */
- (nullable NSString *)getStringOptionWithKey:(NSString *)key;

/**
 @abstract Returns the numerical option associated with the given key.
 @discussion Call this method using one of the string-based metadata keys in your subclass to get the corresponding value.
 @param key A string-based option key.
 @return The option value associated with the given key. Returns `nil` if the option has not been set.
 @see AdColonyAppOptions
 @see AdColonyAdOptions
 */
- (nullable NSNumber *)getNumericOptionWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END