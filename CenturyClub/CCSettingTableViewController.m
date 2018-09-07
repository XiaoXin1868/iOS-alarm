//
//  CCSettingTableViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCSettingTableViewController.h"
#import "DAKeyboardControl.h"
#import "SVProgressHUD.h"
#import "PinViewController.h"
#import "Theme.h"
#import "User.h"
#import "BraintreeManager.h"
#import "WSManager.h"
#import "DateManager.h"
#import "UIView+Toast.h"

@interface CCSettingTableViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, PinViewControllerDelegate, UITextFieldDelegate, BraintreeManagerDatasource, BraintreeManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>{
    MembershipType _clubType;
    NSString *_paymentMethodNonce;
}

- (IBAction)logoutButtonTouched:(id)sender;

//Pin Stuff
- (IBAction)pinWhileOrderingSwitchChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *pinActiveSwitch;
@property (strong, nonatomic) PinViewController *pinViewController;

//
@property (weak, nonatomic) IBOutlet CCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CCTextField *contactTextField;

@property (weak, nonatomic) IBOutlet CCTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet CCTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet CCTextField *addressLine1TextField;
@property (weak, nonatomic) IBOutlet CCTextField *addressLine2TextField;
@property (weak, nonatomic) IBOutlet CCTextField *cityTextField;
@property (weak, nonatomic) IBOutlet CCTextField *stateTextField;
@property (weak, nonatomic) IBOutlet CCTextField *zipTextField;

- (IBAction)saveButtonTouched:(id)sender;
- (IBAction)cancelButtonTouched:(id)sender;

//membership
@property (weak, nonatomic) IBOutlet UILabel *memberSinceLabel;

@property (weak, nonatomic) IBOutlet UILabel *membershipExpireTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *membershipExpiersLabel;
@property (weak, nonatomic) IBOutlet CCThemeButton *membreshipExpiredButton;
- (IBAction)membreshipExpiredButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currentMembershipTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *membershipRenewDateLabel;

@property (weak, nonatomic) IBOutlet UISwitch *autoReniewSwitch;
- (IBAction)autoReniewSwitchValueChanged:(id)sender;

//
//member ship button
@property (weak, nonatomic) IBOutlet CCThemeButton *quarterCenturyButton;
@property (weak, nonatomic) IBOutlet CCThemeButton *halfCenturyButton;
@property (weak, nonatomic) IBOutlet CCThemeButton *centuryButton;
- (IBAction)clubTypeButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet CCThemeButton *cancelMembershipButton;
- (IBAction)cancelMembershipButtonTouched:(id)sender;

//order
@property (weak, nonatomic) IBOutlet UILabel *remainingOrderLabel;

//
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerViewDSArray;

//
@property (strong, nonatomic) NSDictionary *userDetail;

@end

@implementation CCSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // for scroll down to hide keyboard implementation
    //for scroll down to hide keyboard implementation
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
    } constraintBasedActionHandler:nil];
    
    //initialise brain tree
    [BRAIN_TREE setDelegate:(id<BraintreeManagerDelegate>)self];
    [BRAIN_TREE setDatasource:(id<BraintreeManagerDatasource>)self];
    
    //set theme background
    [self.view setBackgroundColor:[Theme themeBGColor]];
    
    //
    [_contactTextField setDelegate:self];
    [_zipTextField setDelegate:self];

    //
    _pinViewController = [[PinViewController alloc] initWithNibName:@"PinViewController" bundle:[NSBundle mainBundle]];
    [_pinViewController setDelegate:self];
    
    //picker view stuff
    _pickerViewDSArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USStates" ofType:@"plist"]];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _stateTextField.inputView = _pickerView;
    
    //
    [self displayCurrentUserSettings:[USER userDetail]];
    
    //refresh data from server
    
    //
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
{
    "address_line_1" = "Add 1";
    "address_line_2" = "Add 2";
    amount = 0;
    "autorenew_membership" = 0;
    city = City;
    email = a124;
    "expiery_date" = "2015-09-02 02:14:07 +0000";
    "first_name" = A;
    "last_name" = 124;
    "member_since" = "2015-08-03 02:14:07 +0000";
    "membership_type_id" = 2;
    password = aaaaaaaa;
    "payment_nonce" = "";
    "phone_number" = 1212121212;
    pin = 1234;
    referal = 121212121;
    "credits" = 10;
    "show_pin" = 0;
    state = "New Hampshire";
    zip = 12121;
}*/
 

- (void) displayCurrentUserSettings : (NSDictionary *) userDetail {
    _userDetail = userDetail;

    //set basic details to display
    _emailTextField.text = userDetail[@"email"];
    _contactTextField.text = userDetail[@"phone_number"];
    _firstNameTextField.text = userDetail[@"first_name"];
    _lastNameTextField.text = userDetail[@"last_name"];
    _addressLine1TextField.text = userDetail[@"address_line_1"];
    _addressLine2TextField.text = userDetail[@"address_line_2"];
    _cityTextField.text = userDetail[@"city"];
    _stateTextField.text = userDetail[@"state"];
    _zipTextField.text = userDetail[@"zip"];
    
    
    //
    NSDate *date = [USER memberSinceDate];
    _memberSinceLabel.text = [date dateStringOfFormat:@"MMMM YYYY"];
    date = [USER memberShipExpiryDate];
    _membershipExpiersLabel.text = [date dateStringOfFormat:@"MMMM dd, YYYY"];
    BOOL membershipExpired = [USER isMemberShipExpired];
    [_memberSinceLabel setHidden:membershipExpired];
    [_membershipExpireTitleLabel setHidden:membershipExpired];
    [_membreshipExpiredButton setHidden:!membershipExpired];
    _currentMembershipTypeLabel.text = [USER currentMembershipName];
    _membershipRenewDateLabel.text = [[date dateByAddingDays:1] dateStringOfFormat:@"MMM dd, YYYY"];
    
    //set membership buttton UI
    MembershipType club = (MembershipType) [userDetail[@"membership_type_id"] integerValue];
    [self uiUpdateFor:club];
    
    //remaining order
    _remainingOrderLabel.text = [userDetail[@"credits"] stringValue];

    //
    [_pinActiveSwitch setOn:[USER shouldShowPin]];
    [_autoReniewSwitch setOn:[userDetail[@"autorenew_membership"] boolValue]];
}

- (void) refreshData {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Refreshing!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGetProfile]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"responseObject = %@", responseObject);
             if ([responseObject[@"status"] integerValue] == 1) {
                 [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done!", nil)];
                 [USER saveUserDetail:responseObject[@"user"]];
                 [self displayCurrentUserSettings:responseObject[@"user"]];
             }else{
                 [SVProgressHUD showErrorWithStatus:nil];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
             NSLog(@"error = %@", error.localizedDescription);
         }];
}

- (void) deselectAll {
    [_quarterCenturyButton setSelected:NO];
    [_halfCenturyButton setSelected:NO];
    [_centuryButton setSelected:NO];
}

- (void) uiUpdateFor : (MembershipType) club {
    //
//    [_centuryButton setUserInteractionEnabled:YES];
//    [_halfCenturyButton setUserInteractionEnabled:YES];
//    [_quarterCenturyButton setUserInteractionEnabled:YES];
    
    //
    [self deselectAll];
    //
    [_cancelMembershipButton setEnabled:![USER memberShipCanceled]];//set it according to bit

    //
    switch (club) {
        case MembershipTypeCentury:
            [_centuryButton setSelected:YES];
//            [_centuryButton setUserInteractionEnabled:NO];
            break;
        case MembershipTypeHalfCentury:
            [_halfCenturyButton setSelected:YES];
//            [_halfCenturyButton setUserInteractionEnabled:NO];
            break;
        case MembershipTypeQuarterCentury:
            [_quarterCenturyButton setSelected:YES];
//            [_quarterCenturyButton setUserInteractionEnabled:NO];
            break;
        case MembershipTypeReferal:
        case MembershipTypeNone:
            [_cancelMembershipButton setEnabled:NO];//force disable it in case if non cancelable membership type
            break;
            
        default:
            break;
    }
}

- (IBAction)logoutButtonTouched:(id)sender {
    //set user detail to nil
    [USER saveUserDetail:nil];
    [BRAIN_TREE getClientToken];//update client token
    
    //
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Pin Stuff
- (IBAction)pinWhileOrderingSwitchChanged:(id)sender {
    //set delegate
    [self presentViewController:_pinViewController animated:YES completion:^{
        [_pinViewController setDelegate:(id<PinViewControllerDelegate>)self];
    }];
}

//delegate
- (NSString *) getCurrentPin:(PinViewController *)controller {
    return [USER currentPin];
}

- (void) pinController : (PinViewController *) controller pin : (NSString *) pin withStatus : (PinStatus) pinStatus {
    NSDictionary *dictionary = nil;
    switch (pinStatus) {
        case PinStatusMatched:
            [_pinActiveSwitch setOn:NO];
            [USER setChangedPin:nil];
            dictionary = @{@"pin_when_ordering": @(NO),
                           @"pin": @""};
            break;
        case PinStatusCreated:
            [USER setChangedPin:pin];
            dictionary = @{@"pin_when_ordering": @(YES),
                           @"pin": pin};
            break;
        case PinStatusNone:
            [_pinActiveSwitch setOn:[USER shouldShowPin]];
            break;
        default:
            break;
    }
    
    //update api if pin changed
    if (dictionary!=nil)
        [self callUpdateApi:dictionary];
}

#pragma mark - Text Field
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
//    _tipTextTextField.text = _pickerDSArray[[_pickerView selectedRowInComponent:0]][@"textTitle"];
}

- (IBAction)saveButtonTouched:(id)sender {
    //validat fields and do nothing if it is not valid
    if (![self isDataValid])
        return;
    
    NSDictionary *dictinary = @{@"email" : _emailTextField.text,
                                @"phone_number":_contactTextField.text,
                                @"first_name":_firstNameTextField.text,
                                @"last_name":_lastNameTextField.text,
                                @"address_line_1":_addressLine1TextField.text,
                                @"address_line_2":_addressLine2TextField.text,
                                @"city":_cityTextField.text,
                                @"state":_stateTextField.text,
                                @"zip":_zipTextField.text,
                                @"membership_type":[NSNumber numberWithInteger:_clubType]};
    [self callUpdateApi:dictinary];
    
    //end editing
    [self.view endEditing:YES];
}

- (void) callUpdateApi : (NSDictionary *) user {
    //create parameter list
    NSDictionary *parameters = @{@"user_id":[USER userId],
                                 @"auth_token":[USER authToken],
                                 @"user" : user
                                 };
    NSLog(@"parameters = %@", parameters);
    
    //
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating!", nil) maskType:SVProgressHUDMaskTypeClear];
    [manager PATCH:[WSMANAGER URLfor:WSRequestUpdateProfile]
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               NSLog(@"responseObject = %@", responseObject);
               if ([responseObject[@"status"] integerValue] == 1) {
                   [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done!", nil)];
               }
               else{
                   [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"]
                                     status:[NSString stringWithFormat:@"%@",responseObject[@"message"]]];
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [self.view makeToast:error.localizedDescription];
               [SVProgressHUD dismiss];
           }];
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self displayCurrentUserSettings:_userDetail];
}

- (IBAction)autoReniewSwitchValueChanged:(id)sender {
    UISwitch *autoRenewSwitch = (UISwitch *) sender;
    NSDictionary *dictinary = @{@"autorenew_membership" : @(autoRenewSwitch.isOn)};
    [self callUpdateApi:dictinary];
}

- (IBAction)membreshipExpiredButtonTouched:(id)sender {
    
}

- (IBAction)cancelMembershipButtonTouched:(id)sender {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Confirm, canceling %@ membership.", nil), [USER membershipName:[USER currentMembership]]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alert.tag = 102;
    [alert show];
}

- (void) cancelMembership{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Canceling..", nil)];
    [manager POST:[WSMANAGER URLfor:WSRequestCancelMembership]
       parameters:@{@"user_id":[USER userId], @"auth_token":[USER authToken]}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              if ([responseObject[@"status"] integerValue] == 1) {
                  [USER saveUserDetail:responseObject[@"user"]];
                  [self displayCurrentUserSettings:[USER userDetail]];
                  if ([USER remainingCredits] > 0)
                      [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Canceled! \n However, credits left to be used in this month"]];
                  else
                      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Canceled!", nil)];
                  
              }else{
                  [SVProgressHUD showErrorWithStatus:[responseObject[@"message"] stringByAppendingString:@"\n Try after sometime."]];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error = %@", error.localizedDescription);
              [SVProgressHUD showErrorWithStatus:error.localizedDescription];
              [self displayCurrentUserSettings:[USER userDetail]];
          }];
}

- (BOOL) isDataValid {
    if (![_emailTextField.text length]) {
        [_emailTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter email!", nil)];
        
        return NO;
    }else if (![_contactTextField.text length]) {
        [_contactTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter contact number!", nil)];
        return NO;
    }else if(![_firstNameTextField.text length]){
        [_firstNameTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter first name.", nil)];
        return NO;
    }else if(![_lastNameTextField.text length]){
        [_lastNameTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter last name.", nil)];
        return NO;
    }else if(![_addressLine1TextField.text length]){
        [_addressLine1TextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Please enter your address.", nil)];
        return NO;
    }else if(![_cityTextField.text length]){
        [_cityTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter your city.", nil)];
        return NO;
    }else if(![_stateTextField.text length]){
        [_stateTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Choose state.", nil)];
        return NO;
    }else if(![_zipTextField.text length]){
        [_zipTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Enter zip code.", nil)];
        return NO;
    }else if (_clubType == MembershipTypeNone){
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Provide a valid referral number or select a membership.", nil)];
        return NO;
    }else if ((_clubType == MembershipTypeCentury ||
               _clubType == MembershipTypeHalfCentury ||
               _clubType == MembershipTypeQuarterCentury) && _paymentMethodNonce.length == 0){
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Wait untill payment is authenticated.", nil)];
        return NO;
    }
    return YES;
}

#pragma mark - UITextField Delegate
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByAppendingString:string];
    if ([textField isEqual:_contactTextField]) {
        if (newString.length > 10) {//phone number can't be greater  than 10 digits
            [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"phone number can't be greater  than 10 digits", nil)];
            return NO;
        }
    }else if ([textField isEqual:_zipTextField]) {
        if (newString.length > 5) {//phone number can't be greater  than 10 digits
            return NO;
        }
    }
    return YES;
}

- (IBAction)clubTypeButtonTouched:(id)sender {
    [self.view endEditing:YES];
    UIButton *button = (UIButton *)sender;
    [self deselectAll];
    [button setSelected:YES];
    
    if ([button isEqual:_quarterCenturyButton]) {
        _clubType = MembershipTypeQuarterCentury;
    }else if ([button isEqual:_halfCenturyButton]) {
        _clubType = MembershipTypeHalfCentury;
    }else if ([button isEqual:_centuryButton]) {
        _clubType = MembershipTypeCentury;
    }
    
    if (_clubType == [USER currentMembership] && ![USER memberShipCanceled])
        return;
    
    if ([USER currentMembership] == MembershipTypeReferal || [USER currentMembership] == MembershipTypeNone)
        [self callPaymentMethod];
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[self changeActionMessage:_clubType current:[USER currentMembership]] delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alert.tag = 101;
        [alert show];
    }
}

- (BOOL) isDowngrading : (MembershipType) new current : (MembershipType) current {
    return (current > new);
}

- (NSString *) changeActionMessage : (MembershipType) new current : (MembershipType) current {
    switch ([USER membershipChange:current to:new]) {
        case MembershipChangeUpgrading:
            return [NSString stringWithFormat:NSLocalizedString(@"Confirm upgrading membership, from %@ to %@", nil), [USER membershipName:[USER currentMembership]], [USER membershipName:_clubType]];
            break;

        case MembershipChangeDowngrading:
            return [NSString stringWithFormat:NSLocalizedString(@"Confirm downgrading membership, from %@ to %@%@", nil), [USER membershipName:[USER currentMembership]], [USER membershipName:_clubType], NSLocalizedString(@". Effective from new payment cycle.", nil)];
            break;

        case MembershipChangeReactivating:
            return [NSString stringWithFormat:NSLocalizedString(@"Confirm reactivating %@ membership", nil), [USER membershipName:[USER currentMembership]]];//once user cncedled his membership and click on same again
            break;
            
        default:
            break;
    }
    return nil;
}

- (void) callPaymentMethod {
    //invoke brain tree for payment
    if (([USER membershipChange:[USER currentMembership] to:_clubType] == MembershipChangeUpgrading
        || [USER membershipChange:[USER currentMembership] to:_clubType] == MembershipChangeNone)
        && _paymentMethodNonce == nil
        && !_paymentMethodNonce.length)
        [BRAIN_TREE invokePayment:PaymentTypeMemberShipUpdate];
    else{
        [self change:[USER membershipChange:[USER currentMembership] to:_clubType] membership:_paymentMethodNonce];
    }
}

//alert view delagate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101){
        if (buttonIndex == 1)
            [self callPaymentMethod];
        else
            [self uiUpdateFor:[USER currentMembership]];
    }else if (alertView.tag == 102) {
        if (buttonIndex == 1)
            [self cancelMembership];
    }
}

#pragma mark - BraintreeManager
//Datasource
- (UIViewController *) manager : (BraintreeManager *) manager callerViewControllerFor : (PaymentType) paymentType {
    return self;
}

//BraintreeManagerDelegate
- (void) manager : (BraintreeManager *) manager payment : (PaymentType) paymentType succeded : (BOOL) condition message : (NSString *) message {
    if (!condition)
        [self uiUpdateFor:[USER currentMembership]];
}

//
- (void) manager:(BraintreeManager *)manager payment:(PaymentType)paymentType nonce:(NSString *)paymentMethodNonce {
    if (paymentType == PaymentTypeMemberShipUpdate) {
        _paymentMethodNonce = paymentMethodNonce;
        [self change:[USER membershipChange:[USER currentMembership] to:_clubType] membership:_paymentMethodNonce];
    }
}


/*
{
    "user_id": 2,
    "auth_token": "qdVYyGN6zmztg3NXqXRJNWh6",
    "user":
    {
        "membership_type_id": "5",
        "amount": "25",
        "payment_method_nonce" : "fake-paypal-future-nonce"
    }
}
*/


- (void) change : (MembershipChange) membershipChange membership : (NSString *) nonce {
    //call it
//    MembershipType currentClub = [USER currentMembership];
//    CGFloat price = [USER priceToUpgrade:_clubType from:currentClub];
//    NSInteger newCredit = [USER creditsWhenUpgrading:_clubType from:currentClub] + [USER remainingCredits];
//    NSDate *date = [USER dateWhenUpgrading:_clubType from:currentClub];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"membership_type_id": @(_clubType)}];
    if (membershipChange == MembershipChangeUpgrading || membershipChange == MembershipChangeNone) {
        [dictionary setObject:@([USER priceToUpgrade:_clubType from:[USER currentMembership]]) forKey:@"amount"];
        [dictionary setObject:nonce forKey:@"payment_method_nonce"];
//        [dictionary setObject:@"fake-paypal-future-nonce" forKey:@"payment_method_nonce"];
    }
    NSDictionary *parameters = @{@"user_id":[USER userId],
                                 @"auth_token":[USER authToken],
                                 @"user":dictionary};
    NSLog(@"parameters = %@", parameters);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Processing..", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestUpgradeMembership]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              if ([responseObject[@"status"] integerValue] == 1) {
                  _paymentMethodNonce = nil;
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done!", nil)];
                  if ([USER brainTreeCustomerId] == nil && responseObject[@"user"][@"customerId"]!=nil) {
                      //set new values
                      [USER saveUserDetail:responseObject[@"user"]];
                      [BRAIN_TREE getClientToken];
                  }
                  
                  //set new values
                  [USER saveUserDetail:responseObject[@"user"]];
              }else{
                  NSString *errorMessage = [WSMANAGER paymentErrorMessage:responseObject];
                  errorMessage = (errorMessage!=nil) ? errorMessage : [NSString stringWithFormat:@"%@", responseObject[@"errors"]];
                  NSLog(@"Message: = %@", [[responseObject[@"errors"][@"payment"] lastObject][@"message"] lastObject]);
                  [SVProgressHUD showErrorWithStatus:errorMessage];
              }
              [self displayCurrentUserSettings:[USER userDetail]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _paymentMethodNonce = nil;
        NSLog(@"error = %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
        [self displayCurrentUserSettings:[USER userDetail]];
    }];
}


#pragma mark - PickerView
//Data Source
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerViewDSArray.count;
}

//UIPickerViewDelegate
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerViewDSArray[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _stateTextField.text = _pickerViewDSArray[row];
}

#pragma mark - TableView
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"indexPath = %@, section = %zd, row = %zd", indexPath.description, indexPath.section, indexPath.row);
    if (indexPath.section == 4 && indexPath.row == 0)
        [BRAIN_TREE invokePayment:PaymentTypeChangeCard];
}

@end