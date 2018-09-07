//
//  Order.h
//  CenturyClub
//
//  Created by Developer on 03/08/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@class Order;
//@protocol OrderDelegate <NSObject>
//@optional
//- (void) order : (NSDictionary *) order placed : (BOOL) placed;
//
//@end

#define ORDER [Order instance]

typedef enum {
    OrderErrorNone = 0,
    OrderErrorTime = 1,
    OrderErrorLowCredits = 2,
    OrderErrorPowerLossBeforeSwipe = 3,
    OrderErrorPowerLossAfterSwipe = 4,
    OrderErrorNothingSelected = 5,
}OrderError;

@interface Order : NSObject

//@property (nonatomic, strong) id <OrderDelegate> delegate;

+ (id) instance;
//validation
- (OrderError) errorInOrder : (NSDictionary *) orderDictionary;
- (NSString *) orderErrorMessage : (OrderError) orderError;

- (BOOL) someThingToOrder;
//calculation
- (CGFloat) orderCost;
- (CGFloat) grossCost;
- (CGFloat) tip;
- (NSInteger) numberOfDrinks;
- (BOOL) isLimit : (NSDictionary *) orderDictionary;

//data
- (void) setLastOrderTime : (NSDate *) time;
- (NSDate *) lastOrderTime;

//
- (void) saveOrderWith : (OrderError) error orderId : (NSString *) orderId paymentDetail : (NSDictionary *) paymentDetail;
- (void) removeOrder : (NSString *) orderId;
- (NSDictionary *) getFailedOrders;

//
- (NSDictionary *) createOrderVerificationDictionary;

//thisOrderId
- (void) setThisOrderId : (NSString *) orderId;
- (NSString *) thisOrderId;

@end