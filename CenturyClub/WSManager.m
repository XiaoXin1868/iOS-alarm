//
//  SCWSPostManager.m
//  Crew Gate
//
//  Created by Developer on 13/11/14.
//  Copyright (c) 2014 tchnologies33. All rights reserved.
//

#import "WSManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "User.h"
#import "Order.h"
NSString *const kNetworkChangedNotification = @"kNetworkChangedNotification";
NSString *const kCVVErrorMessage = @"Gateway Rejected: cvv";

@interface WSManager()
@property (nonatomic, strong) UIButton *networkStatusButton;

@end

@implementation WSManager

+ (id) instance {
    static WSManager *_instance = nil;
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[WSManager alloc] init];
        }
    }
    return _instance;
}

- (id) init : (id) delegate{
    if (self = [super init]) {
        _delegate = delegate;
        
    }
    return  self;
}

- (id) init {
    if (self = [super init]) {
        //check for network status
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        //
        [self setUpForNetworkReachibility];
    }
    return self;
}

- (BOOL) isNetworkAvaialble {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - Support
- (NSString *) URLfor : (WSRequest) request{
#if IS_DEMO
    NSString *url = @"http://centuryclub.rptwsthi.com/api/v1";
#else
    NSString *url = @"http://centuryclub.rptwsthi.com/api/v1";
#endif
    switch (request) {
        case WSRequestUpdateProfile:
            url = [url stringByAppendingPathComponent:@"user"];
            break;
        case WSRequestLogin:
            url = [url stringByAppendingPathComponent:@"authentication/sign_in"];
            break;
        case WSRequestSignup:
            url = [url stringByAppendingPathComponent:@"authentication/sign_up"];
            break;            
        case WSRequestGetProfile:
            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"user?user_id=%@&auth_token=%@", [USER userId], [USER authToken]]];
            break;
        case WSRequestChangePassword:
            url = [url stringByAppendingPathComponent:@"changePassword"];
            break;
        case WSRequestForgotPassword:
            url = [url stringByAppendingPathComponent:@"forgotPassword"];
            break;
        case WSRequestGetBar:
            url = [url stringByAppendingPathComponent:@"bars?timestamp:"];
            break;
        case WSRequestGetDrinks:
            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"bars/%@/drinks", [USER selectedBarDictionary][@"id"]]];
            break;
        case WSRequestVerifyRefferalCode:
            url = [url stringByAppendingPathComponent:@"authentication/validate_referal?referal=REFER"];
            break;
        case WSRequestResetPassword:
//            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"bars/%@/drinks", [USER selectedBarDictionary][@"id"]]];
            break;
        case WSRequestGetMemberShipType:
            url = [url stringByAppendingPathComponent:@"membership_types"];
            break;
        case WSRequestVerifyOrder:
            url = [url stringByAppendingPathComponent:@"orders"];
            break;
        case WSRequestPlaceOrder:
            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"orders/%@/payment", [ORDER thisOrderId]]];
            break;
        case WSRequestGETOrderHistory:
            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"orders?user_id=%@&auth_token=%@", [USER userId], [USER authToken]]];
            break;
        case WSManagerGetBraintreeToken: {
            NSString *customerId = [USER brainTreeCustomerId];
            customerId = (customerId.length) ? [@"?customer_id=" stringByAppendingString:customerId] : @"";
            url = [url stringByAppendingPathComponent:[NSString stringWithFormat:@"/transactions/token%@", customerId]];
        }
            break;
//            user/upgrade_membership
        case WSRequestUpgradeMembership:
            url = [url stringByAppendingPathComponent:@"user/change_membership"];
            break;
        case WSRequestCancelMembership:
            url = [url stringByAppendingPathComponent:@"user/cancel_membership"];
            break;

        default:
            break;
    }
    NSLog(@"URL String = %@", url);
    return url;
}

#pragma mark  - NetworkAvailability Stuff
- (void) setUpForNetworkReachibility{
    
    //setup button
    CGRect frame = CGRectZero;
    //left to right
    //    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    //    frame.size.height = 32.0f;
    //    frame.origin.x = [[UIScreen mainScreen] bounds].size.width;
    //    frame.origin.y = 64.0f;
    //bottom to up
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    frame.size.height = 32.0f;
    frame.origin.y = [[UIScreen mainScreen] bounds].size.height;
    
    UIButton *noNetworkButton = [[UIButton alloc] initWithFrame:frame];
    [noNetworkButton addTarget:self action:@selector(openSetting:) forControlEvents:UIControlEventTouchUpInside];
    [noNetworkButton setImage:[UIImage imageNamed:@"blockActionIcon.png"] forState:UIControlStateNormal];
    [noNetworkButton setTitle:NSLocalizedString(@"No internet connection :(", nil) forState:UIControlStateNormal];
    [noNetworkButton setBackgroundColor:[UIColor colorWithWhite:0.4f alpha:0.6f]];
    [noNetworkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [noNetworkButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 5)];
    _networkStatusButton = noNetworkButton;
    noNetworkButton = nil;
    
    [APP_DELEGATE.window insertSubview:_networkStatusButton atIndex:1000];
    [APP_DELEGATE.window bringSubviewToFront:_networkStatusButton];
    
    //network status change button
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        BOOL networkAvailable = NO;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"No Internet Connection");
                networkAvailable = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                networkAvailable = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkAvailable = YES;
                break;
            default:
                NSLog(@"Unkown network status");
                networkAvailable = NO;
                break;
        }
        //net no network popup
        [self showNoNetworkButton:!networkAvailable];
        
        // All instances of TestClass will be notified
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNetworkChangedNotification
         object:nil
         userInfo:@{@"isRechable":@(networkAvailable)}];
    }];
}

- (void) openSetting : (id) sender{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void) showNoNetworkButton : (BOOL) condition{
    [_networkStatusButton setAlpha:1.0f];
    
    //left to right
//    CGRect currentFrame = _networkStatusButton.frame;
//    currentFrame.origin.x = (condition) ? [[UIScreen mainScreen] bounds].size.width : 0.0f;
//    _networkStatusButton.frame = currentFrame;

//    CGRect expectedFrame = _networkStatusButton.frame;
//    expectedFrame.origin.x = (condition) ? 0.0f : -[[UIScreen mainScreen] bounds].size.width;
//
//    [UIView animateWithDuration:(condition)?0.3f:0.0f animations:^{
//        [_networkStatusButton setFrame:expectedFrame];
//    }];
    
    //bottom to up
    CGRect currentFrame = _networkStatusButton.frame;
    currentFrame.origin.y = (condition) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.height + currentFrame.size.height;
    _networkStatusButton.frame = currentFrame;
    
    CGRect expectedFrame = _networkStatusButton.frame;
    expectedFrame.origin.y = (condition) ? [[UIScreen mainScreen] bounds].size.height - expectedFrame.size.height : [[UIScreen mainScreen] bounds].size.height;
    [UIView animateWithDuration:(condition)?0.3f:0.0f animations:^{
        [_networkStatusButton setFrame:expectedFrame];
    }];
    
    [APP_DELEGATE.window bringSubviewToFront:_networkStatusButton];
}

- (void)disolveNetworkNotification:(BOOL) condition{
    float alpha = (condition) ? 0.0f : 1.0f;
    
    [UIView animateWithDuration:0.1f animations:^{
        [_networkStatusButton setAlpha:alpha];
    }];
}



//NSString Error message
- (NSString *) paymentErrorMessage : (id) responseObject {
    NSString *message = NSLocalizedString(@"Something went wrong. Please try again", nil);
    if (responseObject[@"errors"]!=nil) {
        if (responseObject[@"errors"][@"payment"]!=nil && [responseObject[@"errors"][@"payment"] isKindOfClass:[NSArray class]] ) {
            if ([responseObject[@"errors"][@"payment"] lastObject] != nil) {
                if ([responseObject[@"errors"][@"payment"] lastObject][@"message"] != nil && [[responseObject[@"errors"][@"payment"] lastObject][@"message"] isKindOfClass:[NSArray class]]) {
                    message = [[responseObject[@"errors"][@"payment"] lastObject][@"message"] lastObject];
                }
            }
        }
    }
    return message;
}

@end