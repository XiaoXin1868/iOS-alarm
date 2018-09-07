//
//  CCDrinkListTableViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCDrinkListTableViewController.h"
#import "CCOrderVerificationViewController.h"
#import "PinViewController.h"
#import "DAKeyboardControl.h"
#import "User.h"
#import "Utility.h"
#import "UIView+Toast.h"
#import "WSManager.h"
#import "Order.h"
#import "SVProgressHUD.h"


#pragma mark - Order Cells
NSInteger const kMinOrderValue = 0;
NSInteger const kTagIncrimentButton = 1;
NSInteger const kTagDecrimentButton = 2;

NSInteger const kTagAlertCredit = 1;
NSInteger const kTagAlertTime = 2;

@interface SingleOrderCell()


@end
@implementation SingleOrderCell
- (void) awakeFromNib {
}

- (void) setDelegate:(id<OrderCellDetegate>)delegate_ andData : (NSDictionary *) data{
    //
    self.titleLabel.text = data[@"name"];
    self.priceLabel.text = [Utility getLocalizedPrice:[data[@"cost"] integerValue]];
    
    self.delegate = delegate_;
    self.drinkDetail = data;
}

@end
@interface MultipleOrderCell()
@property (nonatomic, strong) IBOutlet UIView *counterView;
@property (nonatomic, strong) IBOutlet UIButton *decrimentButton;
@property (nonatomic, strong) IBOutlet UIButton *incrimentButton;
@property (nonatomic, strong) IBOutlet UITextField *countertextField;
@property (assign) NSInteger drinkCount;

- (IBAction)counterButtonTouched:(id)sender;
- (void) setCustomDrinkCount:(NSInteger)drinkCount;

@end
@implementation MultipleOrderCell
@synthesize drinkDetail;
@synthesize delegate;

- (void) awakeFromNib {
    [self setCustomDrinkCount:0];
    _decrimentButton.tag = kTagDecrimentButton;
    _incrimentButton.tag = kTagIncrimentButton;
    _countertextField.text = [@(kMinOrderValue) stringValue];
    _drinkOrderLimit = [USER myOrderLimit];
//    if (_drinkOrderLimit == 0) {
//        [self showDisabled];
//    }
    
//    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    for (UIView *view in self.contentView.subviews) {
//        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    }

    self.titleLabel.numberOfLines = 0;
    self.detailLabel.numberOfLines = 0;
}

- (void) setDelegate:(id<OrderCellDetegate>)delegate_ andData : (NSDictionary *) data{
    self.titleLabel.text = data[@"name"];
    self.detailLabel.text = data[@"details"];
    self.priceLabel.text = [Utility getLocalizedPrice:[data[@"price"] floatValue]];

    self.delegate = delegate_;
    self.drinkDetail = data;
}

- (void) setCustomDrinkCount:(NSInteger)drinkCount {
    _drinkCount = drinkCount;
    [_countertextField setText:[@(drinkCount) stringValue]];
    [self.delegate orederCell:self orderPlaced:self.drinkDetail count:_drinkCount];
}

- (void) showDisabled {
    [_decrimentButton setImage:[UIImage imageNamed:@"left_arrow_disabled"] forState:UIControlStateNormal];
    [_incrimentButton setImage:[UIImage imageNamed:@"right_arrow_disabled"] forState:UIControlStateNormal];
}

- (void) enableButtons : (BOOL) enable{
    [_incrimentButton setEnabled:enable];
    [_decrimentButton setEnabled:enable];
}

- (IBAction)counterButtonTouched:(id)sender {
    [self enableButtons:YES];
    UIButton *button = (UIButton *) sender;
    NSInteger currentDrinkCount = _drinkCount;
    currentDrinkCount += (button.tag == kTagIncrimentButton) ? 1 : -1;
    
    if (currentDrinkCount >= _drinkOrderLimit){
        currentDrinkCount = _drinkOrderLimit;
        [_incrimentButton setEnabled:NO];
    }
    else if (currentDrinkCount <= kMinOrderValue) {
        currentDrinkCount = kMinOrderValue;
        [_decrimentButton setEnabled:NO];
    }
    
    [self setCustomDrinkCount:currentDrinkCount];
}

@end

#pragma mark -

@interface CCDrinkListTableViewController ()<OrderCellDetegate, PinViewControllerDelegate, UIAlertViewDelegate> {
    BOOL _isOutOfRange;
    BOOL _isOrderLimit;
}
@property (strong, nonatomic) NSArray *drinksArray;
@property (strong, nonatomic) NSMutableDictionary *selectedDrinksDictionary;
- (IBAction)continueButtonTouched:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *continueWith1PDButton;
@property (strong, nonatomic) IBOutlet UIButton *continueWith20PrButton;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) PinViewController *pinViewController;



@end

@implementation CCDrinkListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //
    [_footerView removeFromSuperview];
    
    //
    [self.view setBackgroundColor:[Theme themeBGColor]];
    
    //for scroll down to hide keyboard implementation
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
    } constraintBasedActionHandler:nil];
    
    //
    NSDictionary *dictionary = [USER selectedBarDictionary];
    _selectedDrinksDictionary = [NSMutableDictionary dictionary];
    _isOutOfRange = ([USER unCirtenityRadious] < [dictionary[@"distance"] floatValue]);
    
    //
    [self setupUserInterface:dictionary];
    
    //
    _pinViewController = [[PinViewController alloc] initWithNibName:@"PinViewController" bundle:[NSBundle mainBundle]];
    [_pinViewController setDelegate:self];
    
    //set button title to center
    [_continueWith1PDButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_continueWith20PrButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //
    [self enableContinueButton:[WSMANAGER isNetworkAvaialble]];

    //register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNetworkChangedNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAllInformation];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //unregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Support
- (void) networkChanged : (NSNotification *) notification {
    NSDictionary *dictionary = notification.userInfo;
    [self enableContinueButton:[dictionary[@"isRechable"] boolValue]];
}

- (NSArray *) getDrinksArray : (NSDictionary *) restaurantDictionary {
    return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DrinksList" ofType:@"plist"]];
}

- (void) setupUserInterface : (NSDictionary *) dictionary {
    self.navigationItem.title = dictionary[@"name"];
//    _drinksArray = [self getDrinksArray:dictionary];
//    NSLog(@"_drinksArray = %@", _drinksArray);

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading..", nil)];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGetDrinks]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject[@"status"] integerValue] == 1) {
                 [SVProgressHUD showSuccessWithStatus:nil];
                 NSArray *array = [NSArray arrayWithArray:responseObject[@"drinks"]];
                 NSMutableArray *anotherArray = [NSMutableArray array];
                 for (NSDictionary *drink in array) {
                     NSMutableDictionary *dictionary = [drink mutableCopy];
                     [dictionary removeObjectForKey:@"availabilities"];
                     [anotherArray addObject:[NSDictionary dictionaryWithDictionary:dictionary]];
                 }
                 _drinksArray = (anotherArray.count) ? anotherArray :_drinksArray;
                 NSLog(@"_drinksArray = %@", _drinksArray);
                 [self reloadAllInformation];
             }else{
                 [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
             NSLog(@"error = %@", error.localizedDescription);
         }];
    [self reloadAllInformation];
}

- (void) reloadAllInformation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _drinksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = _drinksArray[indexPath.row];
//    if ([USER isPriorityCustomer]) {
        // Configuring cell
    MultipleOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"multipleOrderCellIdentifier" forIndexPath:indexPath];
    [cell setDelegate:self andData:dictionary];
    NSDictionary *selectedDataDictionary = _selectedDrinksDictionary[[@(indexPath.row) stringValue]];
    if (selectedDataDictionary != nil)
        cell.countertextField.text = [selectedDataDictionary[@"count"] stringValue];

    //
    [cell.incrimentButton setEnabled:!_isOrderLimit];
    
    return cell;
    
//    }else {
//        SingleOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"singleOrderCellIdentifier" forIndexPath:indexPath];
//        [cell setDelegate:self andData:dictionary];
//        NSDictionary *selectedDataDictionary = _selectedDrinksDictionary[indexPath];
//        if (selectedDataDictionary != nil)
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        return cell;
//    }
//
//    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForDrink:_drinksArray[indexPath.row]];
}

- (CGFloat) heightForDrink : (NSDictionary *) drinkDictionary {
    CGFloat height = [Utility heightForText:drinkDictionary[@"name"] ofFont:[UIFont systemFontOfSize:16.0f] constraintTo:CGSizeMake([UIScreen mainScreen].bounds.size.width - 174.0f, 200.0f)] + 5;
    height += [Utility heightForText:drinkDictionary[@"details"] ofFont:[UIFont systemFontOfSize:14.0f] constraintTo:CGSizeMake([UIScreen mainScreen].bounds.size.width - 174.0f, 200.0f)] + 4;
    height = (height < 44.0f) ? 44.0f : height;
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return _footerView.frame.size.height;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return _footerView;
}

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (![USER isPriorityCustomer]) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            [self orederCell:cell orderPlaced:_drinksArray[indexPath.row] count:0];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        } else {
//            [self orederCell:cell orderPlaced:_drinksArray[indexPath.row] count:1];
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"drinksToOrderVerification"]) {
        CCOrderVerificationViewController *object = (CCOrderVerificationViewController *)[segue destinationViewController];
        object.selectedDrinkDictionary = _selectedDrinksDictionary;
    }else if ([segue.identifier isEqualToString:@"drinksToPin"]) {
        PinViewController *object = (PinViewController *)[segue destinationViewController];
        object.delegate = self;
    }
}

#pragma mark - OrderCellDetegate
- (void) orederCell : (id) cell orderPlaced : (NSDictionary *) drink count : (NSInteger) count {
    if (![USER isLoggedIn]) {
        [self performSegueWithIdentifier:@"drinksToLogin" sender:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }

    UITableViewCell *cell_ = (UITableViewCell *) cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell_];
    NSString *key = [@(indexPath.row) stringValue];
    if (count == 0) {
        [_selectedDrinksDictionary removeObjectForKey:key];
    }
    else{
        NSDictionary *dictionary = @{@"drink": drink,
                                     @"count": @(count)};
        [_selectedDrinksDictionary setObject:dictionary forKey:key];
    }
    
    //is limit
    if ([ORDER isLimit:_selectedDrinksDictionary] || _isOrderLimit != [ORDER isLimit:_selectedDrinksDictionary])//check for limit passed or nany changes made
        [self.tableView reloadData];
    _isOrderLimit = [ORDER isLimit:_selectedDrinksDictionary];//s
}

- (void) enableContinueButton : (BOOL) condition {
    if (condition)
        condition = !_isOutOfRange;

    [_continueWith1PDButton setEnabled:condition];
    [_continueWith20PrButton setEnabled:condition];
}



/*{ "user_id" : 2,
    "auth_token": "qdVYyGN6zmztg3NXqXRJNWh6",
    "order" :
    {
        "number_of_drinks" : 27,
        "order_summaries_attributes":
        {
            "0" :
            {
                "drink_id" : 1,
                "quantity" : 12
            },
            "1" :
            {
                "drink_id" : 2,
                "quantity" : 10
            },
            "2" :
            {
                "drink_id" : 3,
                "quantity" : 5
            }
        }
    }
}*/

- (IBAction)continueButtonTouched:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSArray *tipArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TipCalculation" ofType:@"plist"]];
    [USER setSelectedTip:tipArray[button.tag]];
    
    //check if user is logged-in and then only move to payment
    if (![USER isLoggedIn]) {
        [self performSegueWithIdentifier:@"drinksToLogin" sender:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }
    
    //
    OrderError error = [ORDER errorInOrder:_selectedDrinksDictionary];
    NSString *message = [ORDER orderErrorMessage:error];
    switch (error) {
//        case OrderErrorLowCredits:{
//            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Low Credit", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Setting", nil), nil];
//            alert.tag = kTagAlertCredit;
//            [alert show];
//        }
//            return;
        case OrderErrorNothingSelected:
            [self.view makeToast:message duration:1.0f position:@"top"];
            return;

        case OrderErrorTime:{
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
            alert.tag = kTagAlertTime;
            [alert show];
        }
            return;
            
        default:
            break;
    }
    
    //
    NSDictionary *requestDictionary = [ORDER createOrderVerificationDictionary];
    
    //place request
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Verifying \n order!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestVerifyOrder] parameters:requestDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done!", nil)];
            [ORDER setThisOrderId:responseObject[@"order"][@"id"]];
            [self moveToOrderPage];
        }
        else {
            [SVProgressHUD dismiss];
            [self handleOrderVerificatioError:responseObject[@"errors"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
        return;
    }];
}

- (void) handleOrderVerificatioError : (NSDictionary *) errorDictionary {
    for (NSString *errorKey in errorDictionary.allKeys) {
        if ([errorKey isEqualToString:@"number_of_drinks"]) {
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Low Credit", nil)
                                                              message:[errorDictionary[errorKey] lastObject]
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Setting", nil), nil];
            alert.tag = kTagAlertCredit;
            [alert show];
            break;
        }
    }
}

- (void) moveToOrderPage {
    if ([USER shouldShowPin])
        [self presentViewController:_pinViewController animated:YES completion:nil];
    else
        [self performSegueWithIdentifier:@"drinksToOrderVerification" sender:nil];
}


//
- (IBAction)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PinViewController Delegate
- (void) pinController : (PinViewController *) controller pin : (NSString *) pin withStatus:(PinStatus)pinStatus {
    if (pinStatus == PinStatusMatched) {
        [self performSegueWithIdentifier:@"drinksToOrderVerification" sender:nil];
    }
}

- (NSString *) getCurrentPin : (PinViewController *) controller {
    return [USER currentPin];
}


#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kTagAlertCredit:{
            if (buttonIndex == 1)
                [self performSegueWithIdentifier:@"drinksToSetting" sender:nil];
        }
            break;
        case kTagAlertTime: {
            
        }
            
            break;
            
        default:
            break;
    }
}

@end