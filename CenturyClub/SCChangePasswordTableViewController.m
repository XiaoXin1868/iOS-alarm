//
//  SCChangePasswordTableViewController.m
//  Crew Gate
//
//  Created by Developer on 13/11/14.
//  Copyright (c) 2014 tchnologies33. All rights reserved.
//

#import "SCChangePasswordTableViewController.h"
#import "SVProgressHUD.h"
#import "DAKeyboardControl.h"

@interface SCChangePasswordTableViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *currentPassword;
@property (strong, nonatomic) IBOutlet UITextField *updatedPassword;
@property (strong, nonatomic) IBOutlet UITextField *confirmNewPassword;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
- (IBAction)saveBarButtonTouched:(id)sender;

@end

@implementation SCChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //for scroll down to hide keyboard implementation
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
    } constraintBasedActionHandler:nil];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_currentPassword becomeFirstResponder];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(U ITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)textFieldNextbuttonTouched:(id)sender {
    UITextField *textField = (UITextField *) sender;
    if ([textField isEqual:_currentPassword]) {
        [_updatedPassword becomeFirstResponder];
    }else if ([textField isEqual:_updatedPassword]) {
        [_confirmNewPassword becomeFirstResponder];
    }else{
        [self checkAndCallWebService];
    }
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_confirmNewPassword])
        self.navigationItem.rightBarButtonItem = _saveBarButton;
}


#pragma mark - Web Service Manager
//call web service
- (void)checkAndCallWebService {
    if (![_currentPassword.text length]) {
        [_currentPassword becomeFirstResponder];
        return;
    }
    
    if([_updatedPassword.text length] < 6){
        [_updatedPassword becomeFirstResponder];
        return;
    }
    
    if (![_updatedPassword.text isEqualToString:_confirmNewPassword.text]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Password didn't match!", nil)];
        [_confirmNewPassword becomeFirstResponder];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];

    
    //call webservice to login
//    [_wsManager post:@{@"password":_currentPassword.text, @"newPassword":_updatedPassword.text, @"user_id":[[MetaDetails instance] getUserId]} requestFor:WSRequestChangePassword message:NSLocalizedString(@"Changing password..", nil)];
}

//SCWSManagerDelegate
//- (void) wsManager:(SCWSManager *)manager request:(WSRequest)request finished:(WSResponseStatus)status response:(id)response{
//    if (status == WSResponseStatusFailed) return;
//    
//    if ([response[@"success"] intValue] == 0) {
//        [SCUtility showAlert:response[@"message"]];
//    }else{
//        [SVProgressHUD showSuccessWithStatus:@"Changed!"];
////        [SVProgressHUD showWithStatus:NSLocalizedString(@"Wait..", nil) maskType:SVProgressHUDMaskTypeGradient];
////        + (void)showSuccessWithStatus:(NSString*)string;
////        + (void)showSuccessWithStatus:(NSString*)string;
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

- (IBAction)saveBarButtonTouched:(id)sender {
    self.navigationItem.rightBarButtonItem = nil;
    [self checkAndCallWebService];
}

@end