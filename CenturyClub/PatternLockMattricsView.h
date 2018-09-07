//
//  PatternLockMattricsView.h
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PatternLockMattricsView;
@protocol PatternLockMattricsViewDelegate <NSObject>
- (void) patternDrawingStarted : (NSString *) patternString;
- (void) patternDrawingFinished : (NSString *) patternString;

@end

@interface PatternLockMattricsView : UIView{
    NSMutableArray* _paths;
}

@property (nonatomic, strong) id <PatternLockMattricsViewDelegate> delegate;

// get key from the pattern drawn
- (NSString*)getKey;


@end
