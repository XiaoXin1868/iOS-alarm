//
//  BraintreeManager.m
//  CenturyClub
//
//  Created by Developer on 25/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "BraintreeManager.h"
#import "WSManager.h"
#import "User.h"

@interface BraintreeManager()<BTDropInViewControllerDelegate> {
    NSDate *_lastRecievedTimestamp;
    NSInteger _useCount;
    PaymentType _patmentType;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) BTDropInViewController *dropInViewController;
@property (nonatomic, strong) UIViewController* callerViewController;

@end

@implementation BraintreeManager

+ (id) instance {
    static BraintreeManager *manager = nil;
    @synchronized(self){
        if (manager == nil) {
            manager = [[BraintreeManager alloc] init];
        }
    }
    return manager;
}

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void) setDatasource:(id<BraintreeManagerDatasource>)datasource {
    _datasource = datasource;
    _patmentType = PaymentTypeNone;
        
    if ([_datasource respondsToSelector:@selector(manager:callerViewControllerFor:)])
        _callerViewController = (UIViewController *)[_datasource manager:self callerViewControllerFor:_patmentType];
    
    //retrive client token
    if (self.braintree == nil)
        [self getClientToken];
}

- (void) setDelegate:(id<BraintreeManagerDelegate>)delegate {
    _delegate = delegate;
}

- (void) getClientToken {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSManagerGetBraintreeToken]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             _lastRecievedTimestamp = [NSDate date];
             // Initialize `Braintree` once per checkout session
//             NSLog(@"token = %@", responseObject[@"token"]);
             self.braintree = [Braintree braintreeWithClientToken:responseObject[@"token"]];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         }];
}

#pragma mark - BT Drop in
- (void) invokePayment : (PaymentType) paymentType delegate : (id<BraintreeManagerDelegate>) delegate datasource : (id<BraintreeManagerDatasource>) datasource {
    //setting data source this will get all required information from calling class
    [self setDatasource:datasource];
    
    //
    _delegate = delegate;
    
    //setting paymeent type
    _patmentType = paymentType; //set payment type after datasource as based on this it will automatically invoke payment afrer token retrieve
    
    //invoke payment
    [self invokePayment:paymentType];
}

- (void) invokePayment : (PaymentType) paymentType {
    _patmentType = paymentType;
    
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    
    //Present BTDropInViewController instance
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];

    //
    dropInViewController.callToActionText = NSLocalizedString(@"Pay", nil);
    if (_patmentType == PaymentTypeChangeCard)
        dropInViewController.callToActionText = NSLocalizedString(@"Continue", nil);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    [_callerViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [_callerViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate manager:self payment:_patmentType succeded:NO message:NSLocalizedString(@"Transaction canceled!", nil)];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self postNonceToServer:paymentMethod.nonce]; // Send payment method nonce to your server
    [_callerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [_callerViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate manager:self payment:_patmentType succeded:NO message:NSLocalizedString(@"Transaction canceled!", nil)];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    [_delegate manager:self payment:_patmentType nonce:paymentMethodNonce];
//    [_delegate manager:self payment:_patmentType nonce:@"fake-paypal-future-nonce"]; //testing
}

@end



