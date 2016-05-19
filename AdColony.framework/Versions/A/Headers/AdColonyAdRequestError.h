/**
 *  AdColonyAdRequestError.h
 *  AdColonyAdRequestError
 *
 *  Created by Owain Moss on 3/10/15.
 */

/**
 * AdColony ad request error codes
 */
typedef NS_ENUM(NSUInteger, ADCOLONY_AD_REQUEST_ERROR) {
    
    /** An invalid app id or zone id was specified by the developer or an invalid configuration was received from the server (unlikely). */
    ADCOLONY_AD_ERROR_INVALID_REQUEST = 0,
    
    /** The ad was skipped due to the skip interval setting on the control panel. */
    ADCOLONY_AD_ERROR_SKIPPED_REQUEST,
    
    /** The current zone has no ad fill. */
    ADCOLONY_AD_ERROR_NO_FILL_FOR_REQUEST,
    
    /** Either AdColony has not been configured, is still in the process of configuring, is still downloading assets, or is already showing an ad. */
    ADCOLONY_AD_ERROR_UNREADY
};

@interface AdColonyAdRequestError : NSError
@end
