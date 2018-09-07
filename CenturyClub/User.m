//
//  User.m
//  CenturyClub
//
//  Created by Developer on 05/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "User.h"
#import "Constants.h"
#import "DateManager.h"

@interface User()
@property (nonatomic, strong) NSMutableDictionary *userDetailDictionary;

@end

@implementation User

+ (id) instance {
    @synchronized (self) {
        static User *user = nil;
        if (user == nil) {
            user = [[User alloc] init];
        }
        return user;
    }
}

- (id) init {
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _userDetailDictionary = [[NSMutableDictionary alloc] initWithDictionary:[_userDefaults objectForKey:@"userDetail"]];
    }
    return self;
}

/*{
    "address_line_1" = "Add 1";
    "address_line_2" = "Add 2";
    amount = 0;
    "autorenew_membership" = 0;
    city = City;
    email = a124;
    "expiery_date" = "2015-09-02 02:14:07 +0000";
    "first_name" = A;
    "last_name" = 124;
    "member_since" = "2015-08-03 02:14:07 +0000";
    "membership_type_id" = 2;
    password = aaaaaaaa;
    "payment_nonce" = "";
    "phone_number" = 1212121212;
    pin = 1234;
    referal = 121212121;
    "credits" = 10;
    "show_pin" = 0;
    state = "New Hampshire";
    zip = 12121;
}

{
    "address_line_1" = "add 1";
    "address_line_2" = "add 2";
    "auth_token" = h5JgdLaRa45TJ1JaZjjNLQSC;
    city = City;
    country = USA;
    credits = 40;
    id = 3;
    "phone_number" = 1111111111;
    "pin_when_ordering" = 0;
    "referal_code" = REFER1111111111;
    state = Alaska;
}
*/

//manage user data
- (void) saveUserDetail : (NSDictionary *) userDetail {
    if (userDetail == nil) {
        [_userDefaults removeObjectForKey:@"userDetail"];
        [_userDefaults synchronize];
        _userDetailDictionary = nil;
        return;
    }
    _userDetailDictionary = nil;
    _userDetailDictionary = [userDetail mutableCopy];
    //saving to storage
    [_userDefaults setObject:userDetail forKey:@"userDetail"];
    [_userDefaults synchronize];
}

- (NSDictionary *) userDetail {
    return [_userDefaults objectForKey:@"userDetail"];
}

- (NSString *) userId {
    return [_userDetailDictionary[@"id"] stringValue];
}

- (NSString *) authToken {
    return _userDetailDictionary[@"auth_token"];
}

- (NSString *) brainTreeCustomerId {
    return _userDetailDictionary[@"customerId"];
}

- (BOOL) isLoggedIn {
    return ([self userDetail] != nil);
}

- (NSString *) thisUserKey : (NSString *) keyString {
    NSString *userId = [self userId];
    userId = (userId != nil && [userId length]) ? userId : @"";
    return [keyString stringByAppendingString:userId];
}

//pin stuff
- (BOOL) shouldShowPin {
    return (_userDetailDictionary[@"pin"] != nil && [_userDetailDictionary[@"pin"] length]);
}

- (void) setChangedPin : (NSString *) pin {
    if (pin==nil)
        pin = @"";
    
    [_userDetailDictionary setObject:pin forKey:@"pin"];
    [self saveUserDetail:[NSDictionary dictionaryWithDictionary:_userDetailDictionary]];
}

- (NSString *) currentPin {
    return _userDetailDictionary[@"pin"];
}

//MEMBERSHIP
- (BOOL) memberShipCanceled {
    return [_userDetailDictionary[@"membership_cancelled"] boolValue];
}

- (NSDate *) memberSinceDate {
    NSDate *date = [_userDetailDictionary[@"member_since"] dateFromFromat:kServerDateFormat];
    return (date!=nil) ? date : [NSDate date];
}

- (NSDate *) memberShipExpiryDate {
    NSDate *date = [_userDetailDictionary[@"expiry_date"] dateFromFromat:@"yyyy-MM-dd"];
    return (date!=nil) ? date : [NSDate date];
}

- (BOOL) isAutoRenewEnabled {
    return [_userDetailDictionary[@"autorenew_membership"] boolValue];
}

//check
- (BOOL) isMemberShipExpired {
    NSDate *date = [self memberShipExpiryDate];
    return ([[date maximumValue] compare:[NSDate date]] == NSOrderedAscending);
}

- (NSInteger) remainingCredits {
    return [_userDetailDictionary[@"credits"] integerValue];
}

- (MembershipType) currentMembership {
    return (MembershipType)[_userDetailDictionary[@"membership_type_id"] integerValue];
}

- (NSString *) currentMembershipName {
    return [self membershipName:[self currentMembership]];
}


//testing update membership
//- (void) updateMembership : (MembershipType) clubType credit : (NSInteger) credit expieryDate : (NSDate *) date {
//    [_userDetailDictionary setValue:@(clubType) forKey:@"membership_type_id"];
//    [_userDetailDictionary setValue:@(credit) forKey:@"credits"];
//    [_userDetailDictionary setObject:date forKey:@"expiery_date"];
//    [self saveUserDetail:[NSDictionary dictionaryWithDictionary:_userDetailDictionary]];
//}
//
//- (void) cancelMembership {
//    [_userDetailDictionary setValue:@(MembershipTypeNone) forKey:@"membership_type_id"];
//    [self saveUserDetail:[NSDictionary dictionaryWithDictionary:_userDetailDictionary]];
//}
//
//- (void) updateRemainedCredit : (NSInteger) remainedCredit {
//    [_userDetailDictionary setValue:@(remainedCredit) forKey:@"credits"];
//    [self saveUserDetail:[NSDictionary dictionaryWithDictionary:_userDetailDictionary]];
//}

//MEMBER SHIP DETAIL
/*{
    amount = 50;
    "created_at" = "2015-08-04T20:57:56.546Z";
    credits = 75;
    id = 4;
    identity = 3;
    name = HalfCentury;
    "updated_at" = "2015-08-04T20:57:56.546Z";
}*/
- (NSInteger) myOrderLimit {
    switch ([self currentMembership]) {
        case MembershipTypeCentury:
            return 10;
            break;
        case MembershipTypeHalfCentury:
            return 10;
            break;
        case MembershipTypeQuarterCentury:
            return 2;
            break;
        case MembershipTypeReferal:
            return 1;
            break;
        case MembershipTypeNone:
            return 0;
            break;
            
        default:
            break;
    }
    return 0;
}

- (void) saveMemberShipTypes : (NSArray *) array {
    [_userDefaults setObject:array forKey:@"memberShipTypes"];
    [_userDefaults synchronize];
}

- (NSArray *) membershipDetail {
    NSArray *array = (NSArray *)[_userDefaults objectForKey:@"memberShipTypes"];
    return (array == nil && ![array isKindOfClass:[NSArray class]]) ? nil : array;
}

- (NSDictionary *) membershipDetail : (MembershipType) type {
    NSArray *membershipDetail = [self membershipDetail];
    for (NSDictionary *dictionary in membershipDetail) {
        if (type == ((MembershipType)[dictionary[@"id"] integerValue]))
            return dictionary;
    }
    return nil;
}

- (CGFloat) priceOfMembership : (MembershipType) type {
    return [[self membershipDetail:type][@"amount"] floatValue];
    /*switch (club) {
        case MembershipTypeNone:
            return 0.0f;
            break;
        case MembershipTypeCentury:
            return 140.0f;
            break;
        case MembershipTypeHalfCentury:
            return 75.0f;
            break;
        case MembershipTypeQuarterCentury:
            return 40.0f;
            break;
        case MembershipTypeReferal:
            return 0;
            break;
            
        default:
            break;
    }*/
}

- (NSString *) membershipName : (MembershipType) type {
    switch (type) {
        case MembershipTypeNone:
            return NSLocalizedString(@"None", nil);
        case MembershipTypeReferal:
            return NSLocalizedString(@"Trial", nil);
        case MembershipTypeCentury:
            return NSLocalizedString(@"Century", nil);
        case MembershipTypeHalfCentury:
            return NSLocalizedString(@"HalfCentury", nil);
        case MembershipTypeQuarterCentury:
            return NSLocalizedString(@"QuarterCentury", nil);
        default:
            break;
    }
    
}

- (CGFloat) nameOfMembership : (MembershipType) type {
    return [[self membershipDetail:type][@"amount"] floatValue];
}

- (NSInteger) creditsOfMembership : (MembershipType) type {
    return [[self membershipDetail:type][@"credits"] integerValue];
}

- (MembershipChange) membershipChange : (MembershipType) current to : (MembershipType) new {
    if (current == MembershipTypeNone || current == MembershipTypeReferal)
        return MembershipChangeNone;
        
    if (current == new)
        return MembershipChangeReactivating;//once user cncedled his membership and click on same again
    
    if (current > new)
        return MembershipChangeDowngrading;
    
    return MembershipChangeUpgrading;
}


//Tip management
- (void) setSelectedTip : (NSDictionary *) selectedTip {
    [_userDefaults setObject:selectedTip forKey:[self thisUserKey:@"selectedTip"]];
    [_userDefaults synchronize];
}

- (NSDictionary *) getSelectedTip {
    NSDictionary *dictionary = [_userDefaults valueForKey:[self thisUserKey:@"selectedTip"]];
    if (dictionary == nil) {
        dictionary = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TipCalculation" ofType:@"plist"]] lastObject];
    }
    return dictionary;
}

//support
- (NSInteger) maxCreditFor : (MembershipType) club {
    switch (club) {
        case MembershipTypeCentury:
            return 100;
            break;
        case MembershipTypeHalfCentury:
            return 50;
            break;
        case MembershipTypeQuarterCentury:
            return 25;
            break;
        case MembershipTypeReferal:
            return 10;
            break;
        case MembershipTypeNone:
            return 0;
            break;
            
        default:
            break;
    }
    return 1;
}

//upgrading logic
- (CGFloat) priceToUpgrade : (MembershipType) toClub from: (MembershipType) fromClub {
    CGFloat newPrice = [self priceOfMembership:toClub] - [self priceOfMembership:fromClub];
    return newPrice;
}
//
//- (NSInteger) creditsWhenUpgrading : (MembershipType) toClub from: (MembershipType) fromClub {
//    NSInteger newCredits = [self maxCreditFor:toClub] / 2;
//    return newCredits;
//}
//
//- (NSDate *) dateWhenUpgrading : (MembershipType) toClub from: (MembershipType) fromClub {
//    NSDate *date = [NSDate date];
//    return [date dateByAddingDays:30];
//}

- (CGFloat) unCirtenityRadious {
    return 0.5f;
}

@end

