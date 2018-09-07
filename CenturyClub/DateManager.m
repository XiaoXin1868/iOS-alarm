//
//  DateManager.m
//  Crew Gate
//
//  Created by Developer on 03/12/14.
//  Copyright (c) 2014 tchnologies33. All rights reserved.
//

#import "DateManager.h"

NSString *kServerDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'";

@implementation NSDate (DateAdditions)
- (NSString *) dateStringOfFormat : (NSString *) format{
    NSString *string = [[[DateManager instanse] dateFormatter:format] stringFromDate:self];
    return string;
}

- (NSString *) dateStringOfStyle : (NSDateFormatterStyle) style{
    NSString *string = [[[DateManager instanse] dateFormatterWithStyle:style] stringFromDate:self];
    return string;
}


/** Returns a new NSDate object with the time set to the indicated hour,
 * minute, and second.
 * @param hour The hour to use in the new date.
 * @param minute The number of minutes to use in the new date.
 * @param second The number of seconds to use in the new date.
 */

-(NSDate *) toLocalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) toGlobalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second {
    
//    NSLog(@"date beforechanging hour = %@", self);
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:self];
    [components setHour: hour];
    [components setMinute: minute];
    [components setSecond: second];
    NSDate *newDate = [gregorian dateFromComponents: components];
//    NSLog(@"date after changing hour = %@", newDate);
    
    return newDate;
}

- (NSDate *) maximumValue {
    return [self dateWithHour:23
                       minute:59
                       second:59];
}

/** Returns a new date with the given number of hours added or subtracted.
 * @param hours The number of hours to add or subtract from the date.
 */
-(NSDate*)dateByAddingHours:(NSInteger)hours {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hours];
    
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components toDate:self options:0];
}

-(NSDate*)dateByAddingMinutes:(NSInteger)minutes{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMinute:minutes];
    
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components toDate:self options:0];
}

-(NSDate*)dateByAddingSeconds:(NSInteger)seconds{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setSecond:seconds];
    
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components toDate:self options:0];
}

-(NSDate*)dateByAddingDays:(NSInteger)days {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components toDate:self options:0];
}



- (NSDateComponents *) components{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self];
    return components;
}

- (NSInteger) hour{
    return [self components].hour;
}

- (NSInteger) minute{
    return [self components].minute;
}

- (NSInteger) day{
    return [self components].day;
}

- (NSInteger) month{
    return [self components].month;
}

- (NSInteger) year{
    return [self components].year;
}


@end

@implementation NSString (DateFormatting)
- (NSDate *) dateFromFromat : (NSString *) format{
    return [[[DateManager instanse] dateFormatter:format] dateFromString:self];
}

@end


@implementation DateManager

+ (id) instanse{
    static DateManager *dateManager = nil;
    @synchronized(self){
        if (dateManager == nil) {
            dateManager = [[DateManager alloc] init];
        }
    }
    return dateManager;
}

- (id) init{
    if (self = [super init]) {
        _dateFormater = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (NSDateFormatter *) dateFormatter : (NSString *) format{
    if (_dateFormater == nil) {
        _dateFormater = [[NSDateFormatter alloc] init];
        [_dateFormater setTimeZone:[NSTimeZone localTimeZone]];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [_dateFormater setLocale:usLocale];
        [_dateFormater setDateStyle:NSDateFormatterShortStyle];
    }
    
    [_dateFormater setDateFormat:format];
    return _dateFormater;
}

- (NSDateFormatter *) dateFormatterWithStyle : (NSDateFormatterStyle) formaterStyle{
    if (_dateFormater == nil) {
        _dateFormater = [[NSDateFormatter alloc] init];
    }
    [_dateFormater setDateStyle:formaterStyle];
    return _dateFormater;
}

- (NSDateIntervalFormatter *) dateIntervalFormatter : (NSDateIntervalFormatterStyle) formatStyle{
    return nil;
}

@end