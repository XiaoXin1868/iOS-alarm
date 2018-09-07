//
//  Order.m
//  CenturyClub
//
//  Created by Developer on 03/08/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "Order.h"
#import "User.h"
#import "KeychainItemWrapper.h"
#import "WSManager.h"
#import "Utility.h"

NSInteger const kTimeIntervalSinceLastOrder = 10;

@interface Order()
@property (nonatomic, strong) NSDictionary *orderDictionary;
@property (nonatomic, retain) KeychainItemWrapper *failedOrderItemWrapper;

@end

@implementation Order

+ (id) instance {
    @synchronized (self) {
        static Order *order = nil;
        if (order == nil) {
            order = [[Order alloc] init];
        }
        return order;
    }
}

- (id) init {
    if (self = [super init]) {
        [self initializeKeyChainWrapper];
    }
    return self;
}

//
- (OrderError) errorInOrder : (NSDictionary *) orderDictionary{
    _orderDictionary = orderDictionary;
    
    if (![self someThingToOrder]) {
        return OrderErrorNothingSelected;
    }else if ([USER remainingCredits] < [self numberOfDrinks]){
        return OrderErrorLowCredits;
    }else if ([self timeTillNextOrder] > 0) {
        return OrderErrorTime;
    }
    return OrderErrorNone;
}

- (NSString *) orderErrorMessage : (OrderError) orderError {
    switch (orderError) {
        case OrderErrorNone:
        case OrderErrorPowerLossAfterSwipe:
        case OrderErrorPowerLossBeforeSwipe:
            return nil;
            break;
        case OrderErrorLowCredits:
            return [NSString stringWithFormat:NSLocalizedString(@"You have %zd credits remaining and are trying to order %zd. Please go to Settings to upgrade your membership", nil), [USER remainingCredits], [self numberOfDrinks]];
            break;
        case OrderErrorTime:
            return [NSString stringWithFormat:NSLocalizedString(@"You must wait %@ minutes until your next order. Enjoy your last drink!", nil), [ORDER timeString]];
            break;
        case OrderErrorNothingSelected:
            return NSLocalizedString(@"Nothing to order, please select atleast one drink.", nil);
            break;
            
        default:
            break;
    }
    return @"";
}

- (BOOL) someThingToOrder {
    BOOL shouldMove = NO;
    for (NSString *key in _orderDictionary.allKeys) {
        NSDictionary *dictionary = _orderDictionary[key];
        NSLog(@"dictionary = %@", dictionary);
        if ([dictionary[@"count"] integerValue]) {
            shouldMove = YES;
            break;
        }
    }
    return shouldMove;
}

- (CGFloat) orderCost{
    CGFloat cost = 0.0f;
    for (NSString *key in  _orderDictionary.allKeys) {
        NSDictionary *dictionary = _orderDictionary[key];
        cost += [dictionary[@"count"] integerValue] * [dictionary[@"drink"][@"price"] floatValue];
    }
    return cost;
}

- (CGFloat) grossCost {
    CGFloat cost = [self orderCost];
    CGFloat tip = [self tip];
    cost += tip;
    return cost;
}

- (CGFloat) tip {
    NSDictionary *tipDictionary = [USER getSelectedTip];
    float cost = [self orderCost];
    CGFloat tip = 0;
    if ([tipDictionary[@"unit"] isEqual:@"percent"]) {
        tip = (cost * ([tipDictionary[@"value"] integerValue] * 2)) / 100.0f;// 2 because we show half price of drink in our system but tip neeed to be on full price
    }else /*if ([tipDictionary[@"unit"] isEqual:@"dollar"])*/ {
        tip = [self numberOfDrinks] * [tipDictionary[@"value"] integerValue];
    }
    return tip;
}

- (NSInteger) numberOfDrinks{
    NSInteger count = 0;
    for (NSString *key in _orderDictionary.allKeys) {
        NSDictionary *dictionary = _orderDictionary[key];
        NSLog(@"dictionary = %@", dictionary);
        count += [dictionary[@"count"] integerValue];
    }
    return count;
}

- (BOOL) isLimit : (NSDictionary *) orderDictionary{
    _orderDictionary = orderDictionary;
     return ([self numberOfDrinks] >= [USER myOrderLimit]);
}

//data
- (void) setLastOrderTime : (NSDate *) time {
    [[USER userDefaults] setObject:time forKey:@"lastOrderTime"];
    [[USER userDefaults] synchronize];
}

- (NSDate *) lastOrderTime {
    return [[USER userDefaults] objectForKey:@"lastOrderTime"];
}

- (NSTimeInterval) timeTillNextOrder {
    NSDate *lastTime = [self lastOrderTime];
    NSDate *nextTime = [lastTime dateByAddingTimeInterval:kTimeIntervalSinceLastOrder];
    NSTimeInterval interval = [nextTime timeIntervalSinceDate:[NSDate date]];
    return interval;
}

- (NSString *) timeString {
    NSInteger timeRemained = (NSInteger)[self timeTillNextOrder];
    NSString *timeString = [NSString stringWithFormat:@"%02zd:%02zd", timeRemained/60, timeRemained%60];
    return timeString;
}

#pragma mark - Failed Order
- (void) saveOrderWith : (OrderError) error orderId : (NSString *) orderId paymentDetail : (NSDictionary *) paymentDetail{
    NSMutableDictionary *thisOrder = [[NSMutableDictionary alloc] initWithDictionary:@{@"payment_detail":paymentDetail}];
    [thisOrder setValue:@(error) forKey:@"error"];
    [thisOrder setValue:[[NSDate date] description] forKey:@"failedTime"];

    //add failed orders
    NSMutableDictionary *faiedOrders = [[self getFailedOrders] mutableCopy];
    [faiedOrders setObject:[NSDictionary dictionaryWithDictionary:thisOrder] forKey:orderId];
    [self saveFailedOrders:[NSDictionary dictionaryWithDictionary:faiedOrders]];
}

- (void) removeOrder : (NSString *) orderId {
    _orderDictionary = nil;
    
    NSMutableDictionary *failedOrders = [[self getFailedOrders] mutableCopy];
    //remove object
    [failedOrders removeObjectForKey:orderId];
    
    //save updated array
    [self saveFailedOrders:[NSDictionary dictionaryWithDictionary:failedOrders]];
}


//#warning keychain saving stuff right now some problem with Dictionary to json later will resolve it
- (void) initializeKeyChainWrapper {
    if (_failedOrderItemWrapper == nil) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"FailedOrder" accessGroup:nil];
        _failedOrderItemWrapper = wrapper;
        wrapper = nil;
    }
}

- (void) saveFailedOrders : (NSDictionary *) failedOrderDictionary {
    [[USER userDefaults] setObject:failedOrderDictionary forKey:@"failedOrder"];
//    NSString *failedOrders = [Utility stringFromDictionary:failedOrderDictionary];
//    [_failedOrderItemWrapper setObject:failedOrders forKey:(__bridge id)(kSecValueData)];
}

- (NSDictionary *) getFailedOrders {
//    NSString * failedOrders =  [_failedOrderItemWrapper objectForKey:(__bridge id)(kSecValueData)];//returns @"" in case of blank
//    NSDictionary *failedOrderDictionary = [Utility dictionaryFromString:failedOrders];
    NSDictionary *failedOrderDictionary = [[USER userDefaults] objectForKey:@"failedOrder"];
    failedOrderDictionary = (([failedOrderDictionary isKindOfClass:[NSDictionary class]]) && (failedOrderDictionary != nil || failedOrderDictionary.count != 0)) ? failedOrderDictionary : [NSDictionary dictionary];
//    return failedOrderDictionary;    
    return failedOrderDictionary;
}


//DRINK DETAIL
/*
0:{
    count = 1;
    drink = {
        "bar_id" = 1;
        "created_at" = "2015-08-05T09:44:41.105Z";
        details = "American Lager";
        id = 1;
        name = Guinness;
        price = 2;
        "updated_at" = "2015-08-05T09:44:41.105Z";
    }
}
*/

//CREATE JSON
/*
{ "user_id" : 2,
    "auth_token": "qdVYyGN6zmztg3NXqXRJNWh6",
    "order" :
    {
        "amount" : 934,
        "number_of_drinks" : 27,
        "payment_method_nonce":"fake-paypal-future-nonce",
        "order_summaries_attributes":
        {
            "0" :
            {
                "drink_id" : 1,
                "quantity" : 12
            },
            "1" :
            {
                "drink_id" : 2,
                "quantity" : 10
            },
            "2" :
            {
                "drink_id" : 3,
                "quantity" : 5
            }
        }
    }
}
 */


//
- (NSDictionary *) createOrderVerificationDictionary {
    NSMutableDictionary *orderDictionary = [NSMutableDictionary dictionary];
    [orderDictionary setValue:[USER authToken] forKey:@"auth_token"];
    [orderDictionary setValue:[USER userId] forKey:@"user_id"];
    
    //
    NSMutableDictionary *orderSummeryAttributeDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in _orderDictionary.allKeys) {
        NSDictionary *drinkDetailDictionary = _orderDictionary[key];
        NSDictionary *orderSummery = @{@"drink_id":drinkDetailDictionary[@"drink"][@"id"],
                                       @"quantity":drinkDetailDictionary[@"count"]};
        [orderSummeryAttributeDictionary setObject:orderSummery forKey:key];
    }
    
    //
    NSMutableDictionary *thisOrderDictionary = [NSMutableDictionary dictionary];
    [thisOrderDictionary setObject:@([self numberOfDrinks]) forKey:@"number_of_drinks"];
    [thisOrderDictionary setObject:[NSDictionary dictionaryWithDictionary:orderSummeryAttributeDictionary] forKey:@"order_summaries_attributes"];

    //
    [orderDictionary setObject:[NSDictionary dictionaryWithDictionary:thisOrderDictionary] forKey:@"order"];
    NSLog(@"orderDictionary = %@", orderDictionary);
    
    return [NSDictionary dictionaryWithDictionary:orderDictionary];
}

//thisOrderId
- (void) setThisOrderId : (NSString *) orderId {
    [[USER userDefaults] setValue:orderId forKey:@"ThisOrderId"];
    [[USER userDefaults] synchronize];
}

- (NSString *) thisOrderId {
    return [[USER userDefaults] valueForKey:@"ThisOrderId"];
}

@end