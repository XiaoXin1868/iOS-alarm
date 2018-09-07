//
//  CCOrderVerificationViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCOrderVerificationViewController.h"
#import "SVProgressHUD.h"
#import "Theme.h"
#import "User.h"
#import "Utility.h"
#import "UIView+Toast.h"
#import "Order.h"
#import "BraintreeManager.h"
#import "WSManager.h"
#import "Utility.h"

NSInteger const kTagDrinksTableView = 1;

@implementation SwipeCell



@end

@implementation MoneyCell

@end

@interface CCOrderVerificationViewController ()<PatternLockMattricsViewDelegate, UIAlertViewDelegate, BraintreeManagerDatasource, BraintreeManagerDelegate>{
    NSString *_paymentMethodNonce;
    NSString *_orderIdentifier;
}
@property (nonatomic, strong) NSDictionary *orderDictionary;

@end

@implementation CCOrderVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    [self setupUserInterface];

    //save order in case of power loss but swipe alrady took place
    _orderIdentifier = [Utility getUniqueId];
    [ORDER saveOrderWith:OrderErrorPowerLossBeforeSwipe orderId:_orderIdentifier paymentDetail:[self paymentDictionary:nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Support
- (void) setupUserInterface {
    //
    [self.view setBackgroundColor:[Theme themeBGColor]];
    NSDictionary *dictionary = [USER selectedBarDictionary];
    self.navigationItem.title = dictionary[@"name"];
}

- (NSDictionary *) paymentDictionary : (NSString *) nonce {
    NSMutableDictionary *orderDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"amount":[NSString stringWithFormat:@"%2.2f", [ORDER grossCost]]}];
    if (nonce!=nil)
        [orderDictionary setObject:nonce forKey:@"payment_method_nonce"];
    return  @{@"user_id":[USER userId],
              @"auth_token":[USER authToken],
              @"order":orderDictionary};
}

#pragma mark - Picker
//- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 1;
//}
//
//- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    return _selectedDrinkDictionary.allKeys.count;
//}
//
//- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSDictionary *drinkDictionary = _selectedDrinkDictionary[_selectedDrinkDictionary.allKeys[row]];
//    NSString *drinkDetail = [NSString stringWithFormat:@"%@ (%@)", drinkDictionary[@"drink"][@"name"], drinkDictionary[@"count"]];
//    return drinkDetail;
//}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    //base table one
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //base table one
    switch (section) {
        case 0:
            return 1 + _selectedDrinkDictionary.allKeys.count;;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"orderTitleCellIdentifier" forIndexPath:indexPath];
                    
                    break;
                    
                default:{
                    NSDictionary *drinkDictionary = _selectedDrinkDictionary[_selectedDrinkDictionary.allKeys[indexPath.row-1]];
                    NSString *drinkDetail = [NSString stringWithFormat:@"%@ %@", drinkDictionary[@"count"], drinkDictionary[@"drink"][@"name"]];
                    cell = [tableView dequeueReusableCellWithIdentifier:@"drinkListCellIdentifier" forIndexPath:indexPath];
                    cell.textLabel.numberOfLines = 0;
                    cell.textLabel.text = drinkDetail;
                }
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"tapBelowToConformCell" forIndexPath:indexPath];
                    
                    break;
                case 1:{
                    SwipeCell *cell = (SwipeCell *)[tableView dequeueReusableCellWithIdentifier:@"swipeCell" forIndexPath:indexPath];
                    cell.patternMartrixView.delegate = self;
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0: {
                    MoneyCell * cell = (MoneyCell *)[tableView dequeueReusableCellWithIdentifier:@"moneyCellIdentifier" forIndexPath:indexPath];
                    float cost = [ORDER orderCost];
                    cell.titleLabel.text = NSLocalizedString(@"Order", nil);
                    cell.moneyLabel.text = [Utility getLocalizedPrice:cost];
                    return cell;
                }
                    break;
                    
                case 1: {
                    MoneyCell * cell = (MoneyCell *)[tableView dequeueReusableCellWithIdentifier:@"moneyCellIdentifier" forIndexPath:indexPath];
                    cell.titleLabel.text = NSLocalizedString(@"Tip", nil);
                    cell.moneyLabel.text = [Utility getLocalizedPrice:[ORDER tip]];
                    return cell;
                }
                    break;
                    
                case 2: {
                    MoneyCell * cell = (MoneyCell *)[tableView dequeueReusableCellWithIdentifier:@"moneyCellIdentifier" forIndexPath:indexPath];
                    cell.titleLabel.text = NSLocalizedString(@"Total", nil);
                    cell.moneyLabel.text = [Utility getLocalizedPrice:[ORDER grossCost]];
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    height = 30.0f;
                    break;
                    
                default:{
                    NSDictionary *drinkDictionary = _selectedDrinkDictionary[_selectedDrinkDictionary.allKeys[indexPath.row-1]];
                    NSString *drinkDetail = [NSString stringWithFormat:@"%@ %@", drinkDictionary[@"count"], drinkDictionary[@"drink"][@"name"]];
                    height = [Utility heightForText:drinkDetail ofFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:36.0f] constraintTo:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 30.0f , 200.0f)];
                    height = (height < 44.0f) ? 44.0f : height;
                }
                    break;
            }
            
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    height = 30.0f;
                    
                    break;
                case 1:
                    height = 140.0f;
                    
                    break;
                    
                default:
                    break;
            }
            
            break;
        case 2:
            switch (indexPath.row) {
                case 2:
                    height = 60.0f;
                    break;
                    
                default:
                    height = 30.0f;
                    break;
            }
            break;
            
        default:
            break;
    }
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 12.0f;
    switch (section) {
        case 0:
            
            break;
        case 1:
            height = 32.0f;
            break;
            
        case 2:
            height = 40.0f;
            break;
            
        default:
            break;
    }
    return height;
}

//PatternLockMattricsViewDelegate
- (void) patternDrawingFinished : (NSString *) patternString {
    if (patternString.length > 8)
        patternString = [patternString substringToIndex:8];
    
    NSLog(@"patternString = %@", patternString);
    [self.tableView setScrollEnabled:YES];
    if (![patternString isEqualToString:@"02010304"]) {
        [self.view makeToast:NSLocalizedString(@"Wrong pattern!", ni) duration:1.0f position:@"center"];
        return;
    }
    
    //invoke brain tre payment
    [BRAIN_TREE invokePayment:PaymentTypeDrinksOrder delegate:self datasource:self];
}

- (void) patternDrawingStarted:(NSString *)patternString {
    [self.tableView setScrollEnabled:NO];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - BraintreeManager
- (UIViewController *) manager : (BraintreeManager *) manager callerViewControllerFor : (PaymentType) paymentType {
    return self;
}

//BraintreeManagerDelegate
- (void) manager : (BraintreeManager *) manager payment : (PaymentType) paymentType succeded : (BOOL) condition message : (NSString *) message {
    
}

- (void) manager:(BraintreeManager *)manager payment:(PaymentType)paymentType nonce:(NSString *)paymentMethodNonce {
    _paymentMethodNonce = paymentMethodNonce;

    //save order in case of power loss but swipe alrady took place
    [self makePayment:paymentMethodNonce];
}

- (void) makePayment : (NSString *) nonce{
    //call it
    NSDictionary *parameters = @{@"user_id":[USER userId],
                                 @"auth_token":[USER authToken],
                                 @"order":@{@"amount":[NSString stringWithFormat:@"%2.2f", [ORDER grossCost]],
                                            @"payment_method_nonce":nonce}
                                 };
    NSLog(@"parameters = %@", parameters);
    [ORDER saveOrderWith:OrderErrorPowerLossBeforeSwipe orderId:_orderIdentifier paymentDetail:[self paymentDictionary:nonce]];

    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Placing Order!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestPlaceOrder] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _paymentMethodNonce = nil;
        if ([responseObject[@"status"] integerValue] == 1) {
            NSLog(@"JSON: %@", responseObject);
            [ORDER removeOrder:_orderIdentifier];
            [ORDER setLastOrderTime:[NSDate date]];
            
            //this code will be as it is
            if ([USER brainTreeCustomerId]==nil) {
                [self refreshUserData];// if custermer id is not generated the call this method to generate that
            }else{
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You!", nil) message:NSLocalizedString(@"Order placed successfully.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil] show];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Completed!", nil)];
            }
        }else{
            NSString *errorMessage = [WSMANAGER paymentErrorMessage:responseObject];
            errorMessage = (errorMessage!=nil) ? errorMessage : [NSString stringWithFormat:@"%@", responseObject[@"errors"]];
            NSLog(@"Message: = %@", [[responseObject[@"errors"][@"payment"] lastObject][@"message"] lastObject]);
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {    
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
    }];
}

- (void) refreshUserData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGetProfile]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You!", nil) message:NSLocalizedString(@"Order placed successfully.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil] show];
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Completed!", nil)];

             NSLog(@"responseObject = %@", responseObject);
             if ([responseObject[@"status"] integerValue] == 1) {
                 [USER saveUserDetail:responseObject[@"user"]];
                 if (responseObject[@"user"][@"customerId"]!=nil)
                     [BRAIN_TREE getClientToken];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You!", nil) message:NSLocalizedString(@"Order placed successfully.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil] show];
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Completed!", nil)];
         }];
}



@end