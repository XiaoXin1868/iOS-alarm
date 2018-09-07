//
//  CCDrinkListTableViewController.h
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"

@protocol OrderCellDetegate <NSObject>

@required
- (void) orederCell : (id) cell orderPlaced : (NSDictionary *) drink count : (NSInteger) count;

@end

@interface SingleOrderCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) NSDictionary *drinkDetail;
@property (nonatomic, strong) id <OrderCellDetegate> delegate;
- (void) setDelegate:(id<OrderCellDetegate>)delegate andData : (NSDictionary *) data;

@end

@interface MultipleOrderCell : SingleOrderCell
@property (nonatomic, strong) NSDictionary *drinkDetail;
@property (nonatomic, strong) id <OrderCellDetegate> delegate;
@property (assign) NSInteger drinkOrderLimit;
- (void) setDelegate:(id<OrderCellDetegate>)delegate andData : (NSDictionary *) data;

@end

@interface CCDrinkListTableViewController : UITableViewController

@end