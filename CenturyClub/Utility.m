//
//  Utility.m
//  CenturyClub
//
//  Created by Developer on 05/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "Utility.h"

@implementation Utility
+ (NSString *) getLocalizedPrice : (CGFloat) price {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromNumber:@(price)];
}

+ (CGSize) sizeForText : (NSString *) text ofFont : (UIFont *) font constraintTo : (CGSize) size {
    CGRect frame = [text boundingRectWithSize:size
                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                    attributes:@{NSFontAttributeName:font}
                       context:nil];
    return frame.size;
}

+ (CGFloat) heightForText : (NSString *) text ofFont : (UIFont *) font constraintTo : (CGSize) size {
    return [Utility sizeForText:text ofFont:font constraintTo:size].height;
}


//createUniqueIdentifier
+ (NSString *) getUniqueId{
    CFUUIDRef unqiueId = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, unqiueId);
    CFRelease(unqiueId);
    return [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
}


+ (NSString *) stringFromDictionary : (NSDictionary *) dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = nil;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSDictionary *) dictionaryFromString : (NSString *) string {
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return dictionary;
}

@end