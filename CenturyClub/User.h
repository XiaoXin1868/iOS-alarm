//
//  User.h
//  CenturyClub
//
//  Created by Developer on 05/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define USER [User instance]

typedef enum {
    MembershipTypeNone = 1,
    MembershipTypeReferal = 2,
    MembershipTypeQuarterCentury = 3,
    MembershipTypeHalfCentury = 4,
    MembershipTypeCentury = 5,
}MembershipType;

typedef enum {
    MembershipChangeReactivating,
    MembershipChangeUpgrading,
    MembershipChangeDowngrading,
    MembershipChangeNone
}
MembershipChange;

@interface User : NSObject

///singelton
+ (id) instance;

@property NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDictionary *selectedBarDictionary;

//manage user meta data
- (void) saveUserDetail : (NSDictionary *) userDetail;
- (BOOL) isLoggedIn;
- (NSDictionary *) userDetail;
- (NSString *) userId;
- (NSString *) thisUserKey : (NSString *) keyString;
- (NSString *) authToken;
- (NSDate *) memberSinceDate;
- (NSDate *) memberShipExpiryDate;
- (NSString *) brainTreeCustomerId;
- (BOOL) memberShipCanceled;

//Tip management
- (void) setSelectedTip : (NSDictionary *) selectedTip;
- (NSDictionary *) getSelectedTip;

//pin thing
- (BOOL) shouldShowPin;
- (void) setChangedPin : (NSString *) pin;
- (NSString *) currentPin;

//MEMBERSHIP
//autoreniew membership setting
- (BOOL) isAutoRenewEnabled;

//check
- (BOOL) isMemberShipExpired;
- (MembershipType) currentMembership;
- (NSString *) currentMembershipName;
- (NSInteger) remainingCredits;
- (NSInteger) myOrderLimit; //order limit will always depend on customer's club membership
- (NSString *) membershipName : (MembershipType) type;
- (MembershipChange) membershipChange : (MembershipType) current to : (MembershipType) new;

//update membership
//- (void) updateMembership : (MembershipType) clubType credit : (NSInteger) credit expieryDate : (NSDate *) date;
//- (void) cancelMembership;
//- (void) updateRemainedCredit : (NSInteger) remainedCredit;

//testing membership upgrade
//- (CGFloat) priceToUpgrade : (MembershipType) toClub from: (MembershipType) fromClub;
//- (NSInteger) creditsWhenUpgrading : (MembershipType) toClub from: (MembershipType) fromClub;
//- (NSDate *) dateWhenUpgrading : (MembershipType) toClub from: (MembershipType) fromClub;

//testing
- (NSInteger) maxCreditFor : (MembershipType) club;

//membership detail
- (void) saveMemberShipTypes : (NSDictionary *) dictionary;
- (NSArray *) membershipDetail;
- (NSDictionary *) membershipDetail : (MembershipType) type;
- (CGFloat) priceOfMembership : (MembershipType) type;
- (CGFloat) nameOfMembership : (MembershipType) type;
- (NSInteger) creditsOfMembership : (MembershipType) type;

//upgrading logic
- (CGFloat) priceToUpgrade : (MembershipType) toClub from: (MembershipType) fromClub;

- (CGFloat) unCirtenityRadious;

@end