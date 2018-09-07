//
//  DetailViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCRegistrationTableViewController.h"
#import "DAKeyboardControl.h"
#import "User.h"
#import "Theme.h"
#import "BraintreeManager.h"
#import "UIView+Toast.h"
#import "WSManager.h"
#import "SVProgressHUD.h"
#import "DateManager.h"


@interface CCRegistrationTableViewController ()<UITextFieldDelegate, BraintreeManagerDatasource, BraintreeManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>{
    MembershipType _clubType;
    NSString *_paymentMethodNonce;
}
@property (strong, nonatomic) IBOutlet CCThemeTableViewCell *centuryClubCell;

@property (weak, nonatomic) IBOutlet CCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CCTextField *contactTextField;
@property (weak, nonatomic) IBOutlet CCTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet CCTextField *confirmPassword;

@property (weak, nonatomic) IBOutlet CCTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet CCTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet CCTextField *addressLine1TextField;
@property (weak, nonatomic) IBOutlet CCTextField *addressLine2TextField;
@property (weak, nonatomic) IBOutlet CCTextField *cityTextField;
@property (weak, nonatomic) IBOutlet CCTextField *stateTextField;
@property (weak, nonatomic) IBOutlet CCTextField *zipTextField;
@property (weak, nonatomic) IBOutlet CCTextField *refferalNumberTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signupIndicator;

//member ship button
@property (weak, nonatomic) IBOutlet CCThemeButton *quarterCenturyButton;
@property (weak, nonatomic) IBOutlet CCThemeButton *halfCenturyButton;
@property (weak, nonatomic) IBOutlet CCThemeButton *centuryButton;
- (IBAction)clubTypeButtonTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *referralProgressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signupProgressView;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerViewDSArray;

- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)signupButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet CCThemeButton *signupButton;

@end

@implementation CCRegistrationTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    [_refferalNumberTextField setDelegate:self];
    
    //
    _clubType = MembershipTypeNone;
    
    //
    [_referralProgressView setHidesWhenStopped:YES];
    [_referralProgressView setHidden:YES];
    [_signupProgressView setHidesWhenStopped:YES];
    [_signupProgressView setHidden:YES];
    
    //picker view stuff
    _pickerViewDSArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USStates" ofType:@"plist"]];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _stateTextField.inputView = _pickerView;
    
    //
    _emailTextField.text = _email;
    
    //
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
//- (void) showMembershiploadingFailedAlert {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(@"Couldn't load membership types, due some error.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
//    alertView.tag = 1;
//    [alertView show];
//}
//
//- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 1) {
//        if (buttonIndex == 0) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }else{
//            [self getMemberShipType];//
//        }
//    }
//}



#pragma mark - Sign UP
- (IBAction)signupButtonTouched:(id)sender {
    
    //validat fields and do nothing if it is not valid
    if (![self isDataValid])
        return;
    
    //
    [self registerUser];
}

- (void) registerUser {
    /*
     */
    NSDictionary *user = @{@"email" : _emailTextField.text,
                           @"password" : _passwordTextField.text,
                           @"phone_number":_contactTextField.text,
                           @"first_name":_firstNameTextField.text,
                           @"last_name":_lastNameTextField.text,
                           @"address_line_1":_addressLine1TextField.text,
                           @"address_line_2":_addressLine2TextField.text,
                           @"city":_cityTextField.text,
                           @"state":_stateTextField.text,
                           @"zip":_zipTextField.text,
                           @"country":@"USA",
                           @"membership_type_id":[NSNumber numberWithInteger:_clubType],
                           };
    
    NSMutableDictionary *userDictionay = [user mutableCopy];
    if (_clubType != MembershipTypeReferal) {
        [userDictionay setObject:[NSNumber numberWithInteger:[USER priceOfMembership:_clubType]] forKey:@"amount"];
        [userDictionay setObject:(_clubType != MembershipTypeReferal) ? _paymentMethodNonce : @"" forKey:@"payment_method_nonce"];
    }
    if ([_refferalNumberTextField.text length])
        [userDictionay setObject:[@"REFER" stringByAppendingString:_refferalNumberTextField.text] forKey:@"referal"];
    
    NSDictionary *parameters = @{@"user":userDictionay};
    NSLog(@"parameters = %@", parameters);
    
    //
    [_signupProgressView stopAnimating];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestSignup] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Registered!", nil)];
            [USER saveUserDetail:responseObject[@"user"]];
            if (responseObject[@"user"][@"customerId"]!=nil)
                [BRAIN_TREE getClientToken];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSString *errorMessage = [WSMANAGER paymentErrorMessage:responseObject];
            errorMessage = (errorMessage!=nil) ? errorMessage : [NSString stringWithFormat:@"%@", responseObject[@"errors"]];
            NSLog(@"Message: = %@", [[responseObject[@"errors"][@"payment"] lastObject][@"message"] lastObject]);
            [SVProgressHUD showErrorWithStatus:errorMessage];

            //Gateway Rejected: cvv
            if ([errorMessage isEqualToString:kCVVErrorMessage])
                _paymentMethodNonce=nil;
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
        NSLog(@"Error: %@", error);
    }];
}

- (void) makePayment : (NSDictionary *) parameter{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameter];
    [dictionary setObject:@([USER maxCreditFor:_clubType]) forKey:@"credits"];
    [dictionary setObject:[[NSDate date] dateByAddingDays:30] forKey:@"expiery_date"];
    [dictionary setObject:[NSDate date] forKey:@"member_since"];
    [dictionary setObject:@"" forKey:@"pin"];
    [dictionary setObject:@(NO) forKey:@"autorenew_membership"];
    [USER saveUserDetail:dictionary];

    //call it
    NSDictionary *parameters = @{@"amount":parameter[@"amount"],
                                 @"payment_nonce":parameter[@"payment_nonce"]};

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Registering", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://centuryclub.rptwsthi.com/api/v1/transactions/payment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Registered", nil)];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

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
    }else if([_passwordTextField.text length] < 8) {
        [_passwordTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Insecure password, must be at least 8 characters long!", nil)];
        return NO;
    }else if(![_confirmPassword.text isEqualToString:_passwordTextField.text]){
        [_confirmPassword becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Password didn't match!", nil)];
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
        [_refferalNumberTextField becomeFirstResponder];
        [SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Provide a valid referral number or select a membership.", nil)];
        return NO;
    }else if ((_clubType == MembershipTypeCentury ||
              _clubType == MembershipTypeHalfCentury ||
              _clubType == MembershipTypeQuarterCentury) && _paymentMethodNonce.length == 0) {
        [_signupProgressView setHidden:NO];
        [_signupProgressView startAnimating];
        //invoke brain tree for payment
        if (_paymentMethodNonce == nil && !_paymentMethodNonce.length)
            [BRAIN_TREE invokePayment:PaymentTypeMemberShip];
        return NO;
    }
    return YES;
}

#pragma mark - UITextField Delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:_refferalNumberTextField]) {
        _clubType = MembershipTypeNone;
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByAppendingString:string];
    if ([textField isEqual:_contactTextField]) {
        if (newString.length > 10) {//phone number can't be greater  than 10 digits
            //[SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"phone number can't be greater  than 10 digits", nil)];
            return NO;
        }
    }else if ([textField isEqual:_zipTextField]) {
        if (newString.length > 5) {//phone number can't be greater  than 10 digits
            //[SVProgressHUD showImage:[UIImage imageNamed:@"exclamatory"] status:NSLocalizedString(@"Zip code can't be greater than 5 digits", nil)];
            return NO;
        }
    }else if ([textField isEqual:_refferalNumberTextField]) {
        if (newString.length == 10) {//phone number can't be greater  than 10 digits
            [textField resignFirstResponder];
            textField.text = newString;
            [self verifyReferralCode:newString]; 
        }
    }
    return YES;
}

- (void) verifyReferralCode : (NSString *) referralCode {
    [_referralProgressView setHidden:NO];
    [_referralProgressView startAnimating];
    
    NSString *urlString =  [[WSMANAGER URLfor:WSRequestVerifyRefferalCode] stringByAppendingString:referralCode];
    NSLog(@"refferral urlString = %@", urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"responseObject = %@", responseObject);
             [_referralProgressView stopAnimating];
             if ([responseObject[@"status"] integerValue] == 1) {
                 if (_clubType == MembershipTypeNone)
                     _clubType = MembershipTypeReferal;
                 [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Verified!", nil)];
             }
             else{
                 [_refferalNumberTextField becomeFirstResponder];
                 [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
             [_referralProgressView stopAnimating];
         }];
}

- (IBAction)clubTypeButtonTouched:(id)sender {
    [self.view endEditing:YES];
    UIButton *button = (UIButton *)sender;
    if ([button isSelected]) {
        [button setSelected:NO];
        if ([_refferalNumberTextField.text length])
            _clubType = MembershipTypeReferal;
        _clubType = MembershipTypeNone;
        return;
    }

    [self deselectAll];
    [button setSelected:YES];
    if ([button isEqual:_quarterCenturyButton]) {
        _clubType = MembershipTypeQuarterCentury;
    }else if ([button isEqual:_halfCenturyButton]) {
        _clubType = MembershipTypeHalfCentury;
    }else if ([button isEqual:_centuryButton]) {
        _clubType = MembershipTypeCentury;
    }
}

- (void) deselectAll {
    [_quarterCenturyButton setSelected:NO];
    [_halfCenturyButton setSelected:NO];
    [_centuryButton setSelected:NO];
}

#pragma mark - BraintreeManager
- (UIViewController *) manager : (BraintreeManager *) manager callerViewControllerFor : (PaymentType) paymentType {
    return self;
}

//BraintreeManagerDelegate
- (void) manager : (BraintreeManager *) manager payment : (PaymentType) paymentType succeded : (BOOL) condition message : (NSString *) message {
    if (!condition) {
        [_signupProgressView stopAnimating];
    }
}

- (void) manager:(BraintreeManager *)manager payment:(PaymentType)paymentType nonce:(NSString *)paymentMethodNonce {
    _paymentMethodNonce = paymentMethodNonce;
    [self registerUser];
}

#pragma mark - PickerView
//Delegate
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

//Action
- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
