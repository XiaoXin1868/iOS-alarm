//
//  DateManager.h
//  Crew Gate
//
//  Created by Developer on 03/12/14.
//  Copyright (c) 2014 tchnologies33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    TimeUnitSecond,
    TimeUnitMinute,
    TimeUnitHour,
    TimeUnitDay,
    TimeUnitWeek,
    TimeUnitMonth,
    TimeUnitYear
} TimeUnit;

FOUNDATION_EXPORT NSString *kServerDateFormat;

//NSString Additions
@interface NSDate (DateAdditions)
- (NSString *) dateStringOfStyle : (NSDateFormatterStyle) style;
- (NSString *) dateStringOfFormat : (NSString *) format;
- (NSDate *) dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;
- (NSDate *) maximumValue;
- (NSDate*) dateByAddingHours:(NSInteger)hours;
- (NSDate*) dateByAddingMinutes:(NSInteger)minutes;
- (NSDate*) dateByAddingSeconds:(NSInteger)seconds;
- (NSDate*) dateByAddingDays:(NSInteger)days;
- (NSInteger) hour;
- (NSInteger) minute;
- (NSInteger) day;
- (NSInteger) month;
- (NSInteger) year;

- (NSDate *) toGlobalTime;
- (NSDate *) toLocalTime;

@end

@interface NSString (DateFormatting)
- (NSDate *) dateFromFromat : (NSString *) format;
@end

@interface DateManager : NSObject

@property (nonatomic, strong) NSDateFormatter *dateFormater;
- (NSDateFormatter *) dateFormatter : (NSString *) format;
- (NSDateFormatter *) dateFormatterWithStyle : (NSDateFormatterStyle) formaterStyle;
- (NSDateIntervalFormatter *) dateIntervalFormatter : (NSDateIntervalFormatterStyle) formatStyle;

+ (id) instanse;

@end
