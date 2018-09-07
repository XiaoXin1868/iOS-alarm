//
//  CCOrderVerificationViewController.h
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"
#import "PatternLockMattricsView.h"

@interface SwipeCell : CCThemeTableViewCell
@property (strong, nonatomic) IBOutlet PatternLockMattricsView *patternMartrixView;

@end

@interface MoneyCell : CCThemeTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;

@end

@interface CCOrderVerificationViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *selectedDrinkDictionary;

@end
