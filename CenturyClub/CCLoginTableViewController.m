//
//  MasterViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCLoginTableViewController.h"
#import "CCRegistrationTableViewController.h"
#import "CCResetPasswordTableViewController.h"
#import "DAKeyboardControl.h"
#import "Theme.h"
#import "WSManager.h"
#import "User.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "BraintreeManager.h"

NSInteger const kMaxAttemptBeforeValidate = 5;

@interface CCLoginTableViewController ()<UITextFieldDelegate>{
    NSInteger _invalidAttemptCounter;
}
//sign in
- (IBAction)loginButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet CCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)cancelButtonTouched:(id)sender;

//sing up

@end

@implementation CCLoginTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //for scroll down to hide keyboard implementation
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
    } constraintBasedActionHandler:nil];

    //set delegate to text field
    [_emailTextField setDelegate:self];
    [_passwordTextField setDelegate:self];
    
    //set theme background
    [self.view setBackgroundColor:[Theme themeBGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)loginButtonTouched:(id)sender {
    if (![_emailTextField.text length]) {
        [_emailTextField becomeFirstResponder];
        return;
    }
    
    if(![_passwordTextField.text length]){
        [_passwordTextField becomeFirstResponder];
        [self.view makeToast:NSLocalizedString(@"Enter Password!", nil) duration:1.0f position:@"top"];
        return;
    }
    
    //resign keyboard
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];

    NSDictionary *parameters = @{@"user" :@{@"email" : _emailTextField.text,
                                            @"password" : _passwordTextField.text}};
    NSLog(@"%s parameters = %@", __PRETTY_FUNCTION__, parameters);

    //call it
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging In!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestLogin] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject[@"status"] integerValue] == 1){
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome!", nil)];
            [USER saveUserDetail:responseObject[@"user"]];
            if (responseObject[@"user"][@"customerId"]!=nil)
                [BRAIN_TREE getClientToken];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
            [self performSelector:@selector(takeActionAccordingToLoginError:) withObject:responseObject[@"message"] afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
    }];
}

- (void) takeActionAccordingToLoginError : (NSString *) error {
    if ([error isEqualToString:@"User not found."]) {
        [self performSegueWithIdentifier:@"loginToRegister" sender:_emailTextField.text];
    }else if ([error isEqualToString:@"Incorrect password."]){
        if (_invalidAttemptCounter >= kMaxAttemptBeforeValidate) {
            _invalidAttemptCounter = 0;
            [self performSegueWithIdentifier:@"loginToResetPassword" sender:_emailTextField.text];
        }else{
            _invalidAttemptCounter++;
        }
    }
}

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginToResetPassword"]) {
        CCResetPasswordTableViewController *object = (CCResetPasswordTableViewController *)segue.destinationViewController;
        object.email = [_emailTextField.text isEqual:(NSString *)sender] ? sender : @"";
    }else if ([segue.identifier isEqualToString:@"loginToRegister"]){
        CCRegistrationTableViewController *object = (CCRegistrationTableViewController *)segue.destinationViewController;
        object.email = [_emailTextField.text isEqual:(NSString *)sender] ? sender : @"";
    }
}

//Actions
- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end