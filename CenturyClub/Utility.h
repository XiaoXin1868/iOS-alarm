//
//  Utility.h
//  CenturyClub
//
//  Created by Developer on 05/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject
+ (NSString *) getLocalizedPrice : (CGFloat) price;
+ (CGSize) sizeForText : (NSString *) text ofFont : (UIFont *) font constraintTo : (CGSize) size;
+ (CGFloat) heightForText : (NSString *) text ofFont : (UIFont *) font constraintTo : (CGSize) size;


+ (NSString *) getUniqueId;

//
+ (NSString *) stringFromDictionary : (NSDictionary *) dictionary;
+ (NSDictionary *) dictionaryFromString : (NSString *) string;

@end
