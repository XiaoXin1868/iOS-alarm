//
//  PinViewController.h
//  CenturyClub
//
//  Created by Developer on 06/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    PinStatusMatched,
    PinStatusCreated,
    PinStatusNone
}PinStatus;

@class PinViewController;
@protocol PinViewControllerDelegate <NSObject>

@required
- (NSString *) getCurrentPin : (PinViewController *) controller;

//
- (void) pinController : (PinViewController *) controller pin : (NSString *) pin withStatus : (PinStatus) pinStatus;
@end

@interface PinViewController : UIViewController
@property (nonatomic, strong) id <PinViewControllerDelegate> delegate;
@end
