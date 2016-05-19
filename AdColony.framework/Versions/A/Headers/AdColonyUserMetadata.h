/**
 *  AdColonyUserMetadata.h
 *  AdColonyUserMetadata
 *
 *  Created by Owain Moss on 4/28/16.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 AdColonyUserMetadata objects are used to provide AdColony with per-user, non-personally-identifiable information for ad targeting purposes.
 Note that providing non-personally-identifiable information using this API will improve targeting and unlock improved earnings for your app.
 */
@interface AdColonyUserMetadata : NSObject

/** @name Setting Metadata */

/**
 @abstract Configures the AdColonyUserMetadata object with the given key/value pair.
 @discussion Call this method with one key and one of the pre-defined values below.
 @param key One of the keys defined below.
 @param value One of the pre-defined values below.
 @return Whether the option was set successfully.
 */
- (BOOL)setMetadataWithKey:(NSString *)key andStringValue:(NSString *)value;

/**
 @abstract Configures the AdColonyUserMetadata object with the given key/value pair.
 @discussion Call this method with one of the keys defined below and pass an NSNumber for the value.
 Use this method for configuring the user's age, household income, and location.
 @param key One of the keys defined below.
 @param value An NSNumber representing the value used to configure the metadata option.
 @return Whether the option was set successfully.
 */
- (BOOL)setMetadataWithKey:(NSString *)key andNumericValue:(NSNumber *)value;

/**
 @abstract Configures the AdColonyUserMetadata object with the given key/value pair.
 @discussion Call this method with one of the keys defined below and pass an NSArray for the value.
 Currently, this method should only be used to configure a set of user interests.
 Note that the array must only contain NSStrings.
 @param key One of the keys defined below.
 @param value An NSNumber representing the value used to configure the metadata option.
 @return Whether the option was set successfully.
 */
- (BOOL)setMetadataWithKey:(NSString *)key andArrayValue:(NSArray<NSString *> *)value;


/** @name Metadata Retrieval */

/**
 @abstract Returns the string value associated with the given key in the metadata object.
 @discussion Call this method using one of the string-based metadata keys below to get the corresponding value.
 @param key One of the keys defined below.
 @return The value associated with the given key. Returns `nil` if the value has not been set.
 */
- (nullable NSString *)getStringMetadataWithKey:(NSString *)key;

/**
 @abstract Returns the numeric value associated with the given key in the metadata object.
 @discussion Call this method using one of the string-based metadata keys below to get the corresponding numeric value.
 @param key One of the keys defined below.
 @return The value associated with the given key. Returns `nil` if the value has not been set.
 */
- (nullable NSNumber *)getNumericMetadataWithKey:(NSString *)key;

/**
 @abstract Returns the array value associated with the given key in the metadata object.
 @discussion Call this method using one of the string-based metadata keys below to get the corresponding value.
 Currently, this method should only be used to retrive a set of user interests.
 @param key One of the keys defined below.
 @return The value associated with the given key. Returns `nil` if the value has not been set.
 */
- (nullable NSArray *)getArrayMetadataWithKey:(NSString *)key;
@end

#pragma mark - User Metadata Keys

/**
 * Use the following keys to configure user metadata options.
 */

/** Set the user's age */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_AGE;

/** Set the user's interests */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_INTERESTS;

/** Set the user's gender */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_GENDER;

/** Set the user's current latitude */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_LATITUDE;

/** Set the user's current longitude */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_LONGITUDE;

/** Set the user's annual house hold income in United States Dollars */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_ANNUAL_HOUSEHOLD_INCOME;

/** Set the user's marital status */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_MARITAL_STATUS;

/** Set the user's education level */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_EDUCATION;

/** Set the user's known zip code */
FOUNDATION_EXPORT NSString *const ADC_SET_USER_ZIPCODE;


#pragma mark - User Metadata Values (pre-defined)

/**
 * Use the following pre-defined values to configure user metadata options.
 */

/** User is male */
FOUNDATION_EXPORT NSString *const ADC_USER_MALE;

/** User is female */
FOUNDATION_EXPORT NSString *const ADC_USER_FEMALE;

/** User is single */
FOUNDATION_EXPORT NSString *const ADC_USER_SINGLE;

/** User is married */
FOUNDATION_EXPORT NSString *const ADC_USER_MARRIED;

/** User has a basic grade school education and has not attended high school */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_GRADE_SCHOOL;

/** User has completed at least some high school but has not received a diploma */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_SOME_HIGH_SCHOOL;

/** User has received a high school diploma but has not completed any college */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_HIGH_SCHOOL_DIPLOMA;

/** User has completed at least some college but doesn't have a college degree */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_SOME_COLLEGE;

/** User has been awarded at least 1 associates degree, but doesn't have any higher level degrees */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_ASSOCIATES_DEGREE;

/** User has been awarded at least 1 bachelors degree, but does not have a graduate level degree */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_BACHELORS_DEGREE;

/** User has been awarded at least 1 masters or doctorate level degree */
FOUNDATION_EXPORT NSString *const ADC_USER_EDUCATION_GRADUATE_DEGREE;

NS_ASSUME_NONNULL_END
