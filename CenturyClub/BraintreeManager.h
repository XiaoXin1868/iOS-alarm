//
//  BraintreeManager.h
//  CenturyClub
//
//  Created by Developer on 25/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

typedef enum{
    PaymentTypeMemberShip,
    PaymentTypeMemberShipUpdate,
    PaymentTypeDrinksOrder,
    PaymentTypeChangeCard,
    PaymentTypeNone
} PaymentType;

#define BRAIN_TREE [BraintreeManager instance]

#import <Foundation/Foundation.h>
#import <Braintree/Braintree.h>

@class BraintreeManager;
@protocol BraintreeManagerDatasource <NSObject>
- (UIViewController *) manager : (BraintreeManager *) manager callerViewControllerFor : (PaymentType) paymentType;
@end

@protocol BraintreeManagerDelegate <NSObject>

- (void) manager : (BraintreeManager *) manager payment : (PaymentType) paymentType nonce : (NSString *) paymentMethodNonce;
- (void) manager : (BraintreeManager *) manager payment : (PaymentType) paymentType succeded : (BOOL) condition message : (NSString *) message;

@end

@interface BraintreeManager : NSObject

//
@property (nonatomic, strong) id<BraintreeManagerDelegate> delegate;
@property (nonatomic, strong) id<BraintreeManagerDatasource> datasource;

//
+ (id) instance;
- (void) getClientToken;
- (void) invokePayment : (PaymentType) paymentType ;
- (void) invokePayment : (PaymentType) paymentType delegate : (id<BraintreeManagerDelegate>) delegate datasource : (id<BraintreeManagerDatasource>) datasource;

@end
