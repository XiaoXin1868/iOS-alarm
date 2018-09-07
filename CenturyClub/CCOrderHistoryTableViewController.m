//
//  CCOrderHistoryTableViewController.m
//  CenturyClub
//
//  Created by Developer on 06/08/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCOrderHistoryTableViewController.h"
#import "CCHistoryDetailTableViewController.h"
#import "WSManager.h"
#import "DateManager.h"
#import "SVProgressHUD.h"
#import "Theme.h"
#import "UIView+Toast.h"


@interface CCOrderHistoryTableViewController ()
@property (nonatomic, strong) NSArray *orderArray;
@end

@implementation CCOrderHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupUserInterface];
    
    //
    [self.view setBackgroundColor:[Theme themeBGColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //dismiss hud if snimating
    [SVProgressHUD dismiss];
}

- (void) setupUserInterface {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading!", nil)];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGETOrderHistory]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"responseObject = %@", responseObject);

             if ([responseObject[@"status"] integerValue] == 1) {
                 NSArray *array = responseObject[@"orders"];
                 NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"updated_at"  ascending:NO];
                 _orderArray=[array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
                 NSLog(@"array = %@, _orderArray = %@", array, _orderArray);
                 
                 NSString *message = (_orderArray.count) ? NSLocalizedString(@"Done!", nil) : NSLocalizedString(@"No History!", nil);
                 [SVProgressHUD showSuccessWithStatus:message];

                 [self.tableView reloadData];
             }else{
                 [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
             NSLog(@"error = %@", error.localizedDescription);
         }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _orderArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *orderDictionary = _orderArray[indexPath.row];
    NSDate *date = [orderDictionary[@"updated_at"] dateFromFromat:kServerDateFormat];
    cell.textLabel.text = [date dateStringOfFormat:@"MMM dd, yyyy hh:mm a"];
    cell.detailTextLabel.text = [@"$" stringByAppendingString:[orderDictionary[@"amount"] stringValue]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *orderDetailArray = _orderArray[indexPath.row][@"order_summaries"];
    
    //prepare for segue
    [self performSegueWithIdentifier:@"orderToDetail" sender:orderDetailArray];
}


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
    if ([segue.identifier isEqualToString:@"orderToDetail"]) {
        CCHistoryDetailTableViewController *object = (CCHistoryDetailTableViewController *)segue.destinationViewController;
        object.orderDetailArray = (NSArray *) sender;
    }
}

@end