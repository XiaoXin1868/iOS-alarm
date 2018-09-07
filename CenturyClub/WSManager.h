//
//  SCWSPostManager.h
//  Crew Gate
//
//  Created by Developer on 13/11/14.
//  Copyright (c) 2014 tchnologies33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

//constants
FOUNDATION_EXPORT NSString *const kNetworkChangedNotification;
FOUNDATION_EXPORT NSString *const kCVVErrorMessage;

typedef enum{
    WSRequestGetMemberShipType,
    WSRequestLogin,
    WSRequestSignup,
    WSRequestForgotPassword,
    WSRequestGetProfile,
    WSRequestUpdateProfile,
    WSRequestUpgradeMembership,
    WSRequestCancelMembership,
    WSRequestGetBar,
    WSRequestGetDrinks,
    WSRequestChangePassword,
    WSRequestVerifyRefferalCode,
    WSRequestResetPassword,
    WSRequestSendEmail,
    
    //
    WSRequestVerifyOrder,
    WSRequestPlaceOrder,
    
    //
    WSRequestGETOrderHistory,
    WSManagerGetBraintreeToken
} WSRequest;

typedef enum{
    WSResponseStatusSuccess,
    WSResponseStatusFailed
} WSResponseStatus;

#define IS_DEMO 1
#define WSMANAGER [WSManager instance]

@class WSManager;

@protocol WSManagerDelegate <NSObject>

@required
- (void) wsManager : (WSManager *) manager request : (WSRequest) request finished : (WSResponseStatus) status response : (id) response;

@end

@interface WSManager : NSObject

@property (strong, nonatomic) id <WSManagerDelegate> delegate;
+ (id) instance;
- (BOOL) isNetworkAvaialble;
- (NSString *) URLfor : (WSRequest) request;
- (NSString *) paymentErrorMessage : (id) responseObject;

@end
