//
//  CCHomeTableViewController.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "CCHomeTableViewController.h"
#import "CCDrinkListTableViewController.h"
#import "Theme.h"
#import "User.h"
#import "WSManager.h"
#import "Order.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

NSInteger const kMapSpan = 0.005f;

@implementation MapViewAnnotation
@synthesize coordinate;
@synthesize mTitle,mSubTitle;

-(id)initWithLocation:(CLLocationCoordinate2D)location withTitle:(NSString *)title withSubTitle:(NSString *)subTitle withImage:(UIImage *)locationImage {
    coordinate.latitude = location.latitude;
    coordinate.longitude = location.longitude;
    mTitle = title;
    mSubTitle = subTitle;
    return self;
}

-(NSString *)title {
    return mTitle;
}

-(NSString *)subtitle {
    return mSubTitle;
}

@end

@interface RestaurantCell : CCThemeTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@end

@implementation RestaurantCell

@end

@interface CCHomeTableViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>{
    BOOL _userLocationUpdatedOnce;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray *restaurantArray;
@property (assign) CGFloat uncirtenityRadius;

@property (assign) CLLocationCoordinate2D updatedCoordinate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign) BOOL isUpdating;

@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;

//failed order handling
@property (strong, nonatomic) NSMutableDictionary *failedOrderDictionary;
@property (strong, nonatomic) NSString *failedOrderIdentifier;
@end

@implementation CCHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //
    _userLocationUpdatedOnce = NO;

    //
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    _locationManager = locationManager;
    locationManager = nil;
    [_locationManager startUpdatingLocation];
    _isUpdating = YES;

    //set theme background
    [self.view setBackgroundColor:[Theme themeBGColor]];
    
    //
    [_mapView setShowsUserLocation:YES];
    [_mapView setDelegate:self];
    [_mapView setShowsPointsOfInterest:NO];
    
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"CenturyClub"];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham-Thin" size:20.0f] range:NSMakeRange(0,7)];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham-Bold" size:24.0f] range:NSMakeRange(7,4)];    
    
    //get bar from server and update info
    [self getBarAndUpdateInfo];
    
    _titleLabel.attributedText = string;
    
    
    //check for failed Orders
    [self checkForFailedOrders];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //
    if (_restaurantArray.count == 0)
        [self getBarAndUpdateInfo];
    
    //update right bar button
    [self updateRightBarButtonAction:[USER isLoggedIn]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _restaurantArray.count;
}

/*{
    address = "107 Avenue A. 10009";
    "created_at" = "2015-07-31T20:29:52.790Z";
    id = 7;
    latitude = "40.726233";
    longitude = "-73.983836";
    name = Kazuza;
    "updated_at" = "2015-07-31T20:29:52.790Z";
    "user_id" = 8;
}*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = (RestaurantCell*) [tableView dequeueReusableCellWithIdentifier:@"restauranCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dictionary = _restaurantArray[indexPath.row];
    cell.titleLabel.text = dictionary[@"name"];
    cell.detailLabel.text = dictionary[@"address"];
    
    CGFloat distance = [self getRestaurantDistance:indexPath];
    cell.distanceLabel.text = [self getDistance:distance forUnit:@"mi"];

    //date 2015/08/13 Ayan Asked to allow user to tap on all restaurant
    if (![self withinUncirtenityRadius:distance]) {
        [cell setBackgroundColor:[UIColor colorWithWhite:0.6f alpha:0.2f]];
    }
    
    return cell;
}

- (CGFloat) getRestaurantDistance : (NSIndexPath *) indexPath {
    CGFloat distance = [_restaurantArray[indexPath.row][@"distance"][@"value"] floatValue];
    if (_restaurantArray.count > indexPath.row)
        distance = [_restaurantArray[indexPath.row][@"mi_distance"] floatValue];
    return distance;
}

- (BOOL) withinUncirtenityRadius : (CGFloat) distance{
    return (_uncirtenityRadius > distance);
}

- (NSString *) getDistance : (CGFloat) distace forUnit : (NSString *) unit {
    if ([unit isEqualToString:@"meter"]) {
        if (distace > 1000) {
            distace = distace / 1000;
            return [NSString stringWithFormat:@"%2.2fkm", distace];
        }else{
            return [NSString stringWithFormat:@"%2.2fm", distace];
        }
    }
    return [NSString stringWithFormat:@"%2.2f%@", distace, unit];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if ([self withinUncirtenityRadius:[self getRestaurantDistance:indexPath]])//    //date 2015/08/13 Ayan Asked to allow user to tap on all restaurant

    //calculate distance and send to next page
    CGFloat distance = [self getRestaurantDistance:indexPath];
    NSMutableDictionary *restauranrDictionary = [_restaurantArray[indexPath.row] mutableCopy];
    [restauranrDictionary setObject:@(distance) forKey:@"distance"];
    [self performSegueWithIdentifier:@"homeToDrinkList" sender:[NSDictionary dictionaryWithDictionary:restauranrDictionary]];
    restauranrDictionary = nil;
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

#pragma mark - Support
- (void) getBarAndUpdateInfo {
    //
//    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RestaurantList" ofType:@"plist"]];
//    _restaurantArray = dictionary[@"bars"];
//        [self reloadAllInformation];

    //call it
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading \n Bars", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGetBar]
      parameters:@{@"timestamp":@""}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject[@"status"] integerValue] == 1) {
                 [SVProgressHUD showSuccessWithStatus:nil];
                 _restaurantArray = [NSArray arrayWithArray:responseObject[@"bars"]];
                 [self reloadAllInformation];
             }else{
                 [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
             }
             
             //
             [self getMemberShipType];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
             NSLog(@"error = %@", error.localizedDescription);
             
             //
             [self getMemberShipType];
         }];
    _uncirtenityRadius = .5f;//[dictionary[@"uncertenity_radius"] floatValue];
}

- (void) reloadAllInformation {
    [self reloadRestautantOnMap];
    [self.tableView reloadData];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"homeToDrinkList"]) {
        [USER setSelectedBarDictionary:(NSDictionary *) sender];
    }
}


#pragma mark - Location Management
// LOcation Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //stop after first attempt
    [manager stopUpdatingLocation];
    _isUpdating = NO;
    
//    _updatedCoordinate = newLocation.coordinate;
//    if (![CONSTANTS isUserLocationSaved]) {
//        [self showNewLocation:newLocation.coordinate span:kUserLocationSpan];
//    }
//    _distanceArray = [self distanceArrayFor:_restaurantDictionary[@"restaurants"] from:newLocation];
//    [self.tableView reloadData];
}

- (NSArray *) sortArray : (NSArray *) restaurants forDistanceFrom : (CLLocation *) userLocation {
    NSMutableArray *distanceArray = [NSMutableArray array];
    for (int i = 0; i < restaurants.count; i++) {
        NSMutableDictionary *restaurant = [restaurants[i] mutableCopy];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([restaurant[@"latitude"] doubleValue], [restaurant[@"longitude"] doubleValue]);
        CLLocation *resturantLocation = [[CLLocation alloc] initWithCoordinate:location altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:[NSDate date]];
        CLLocationDistance distance = [userLocation distanceFromLocation:resturantLocation] / 1609.34;//miles
        [restaurant setObject:@(distance) forKey:@"mi_distance"];
        if ([restaurant[@"id"] integerValue] == 5)
            [restaurant setObject:@(0) forKey:@"mi_distance"];
        
        [distanceArray addObject:[NSDictionary dictionaryWithDictionary:restaurant]];
    }
    
    //sort array
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"mi_distance"  ascending:YES];
    NSArray* nearest = [distanceArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"nearest = %@", nearest);
    
    return nearest;
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
}

- (void) requestForLocationAutharization {
    //invoke location
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if (!_userLocationUpdatedOnce) {
        _userLocationUpdatedOnce = YES;
        [self showNewLocation:aUserLocation.coordinate span:kMapSpan];
    }

    //
    _restaurantArray = [self sortArray:_restaurantArray forDistanceFrom:aUserLocation.location];
    [self.tableView reloadData];
}

- (void) showNewLocation : (CLLocationCoordinate2D) newLocation span : (CGFloat) spanDelta{
    MKCoordinateRegion region;
    region.center = newLocation;
    
    MKCoordinateSpan span;
    span.latitudeDelta = spanDelta;
    span.longitudeDelta = spanDelta;
    region.span = span;
    [_mapView setRegion:region animated:YES];
}

#pragma mark - Annotation 
- (void) reloadRestautantOnMap {
    //remove previous ones
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    for (NSDictionary *restaurant in _restaurantArray)
        [self dropRestaurantPin:restaurant];
}

- (void) dropRestaurantPin : (NSDictionary *) restaurant {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([restaurant[@"latitude"] doubleValue], [restaurant[@"longitude"] doubleValue]);
    
    MapViewAnnotation *annot = [[MapViewAnnotation alloc] initWithLocation:coordinate withTitle:restaurant[@"name"] withSubTitle:restaurant[@"address"] withImage:nil];
    [self.mapView addAnnotation:annot];
    annot = nil;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (mapView.userLocation != annotation) {
        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
        annView.pinColor = MKPinAnnotationColorPurple;
        annView.animatesDrop=TRUE;
        annView.canShowCallout = YES;
        annView.calloutOffset = CGPointMake(-9, 0);
        return annView;
    }
    return nil;
}

//Actions
- (void) updateRightBarButtonAction : (BOOL) userLoggedIn {
    //remove all targets
    [_rightBarButton removeTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarButton removeTarget:self action:@selector(settingButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //set target and image accordingly
    if (userLoggedIn) {
        [_rightBarButton setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
        [_rightBarButton addTarget:self action:@selector(settingButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [_rightBarButton setImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
        [_rightBarButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) settingButtonTouched : (id) sender {
    [self performSegueWithIdentifier:@"homeToSetting" sender:nil];
}

- (void) loginButtonTouched : (id) sender {
    [self performSegueWithIdentifier:@"homeToLogin" sender:nil];
}

#pragma mark - Manage Failed Transaction
- (void) checkForFailedOrders {
    _failedOrderDictionary = [[ORDER getFailedOrders] mutableCopy];
    if (_failedOrderDictionary.allKeys.count)
        [self makePayment:_failedOrderDictionary.allKeys.lastObject];
}

//
- (void) makePayment : (NSString  *) orderIdentifier{
    NSDictionary *failedOrder = _failedOrderDictionary[orderIdentifier];
    NSString *url = nil;
    if ([failedOrder[@"error"] integerValue] == OrderErrorPowerLossAfterSwipe) {
        url = [WSMANAGER URLfor:WSRequestPlaceOrder];
    }else if ([failedOrder[@"error"] integerValue] == OrderErrorPowerLossBeforeSwipe) {//Order failed before swipe
        //call webservice to email failed order
        url = [WSMANAGER URLfor:WSRequestSendEmail];
    }
    

    //
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:failedOrder[@"payment_detail"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            NSLog(@"JSON: %@", responseObject);
            [ORDER removeOrder:_failedOrderDictionary.allKeys.lastObject];//remove this order
            [self checkForFailedOrders];//check and update new one
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/*- (void) makePayment : (NSString *) nonce{
    //call it
    NSDictionary *parameters = @{@"user_id":[USER userId],
                                 @"auth_token":[USER authToken],
                                 @"order":@{@"amount":@([ORDER grossCost]),
                                            @"payment_method_nonce":nonce}
                                 };
    NSLog(@"parameters = %@", parameters);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Placing Order!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[WSMANAGER URLfor:WSRequestPlaceOrder] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _paymentMethodNonce = nil;
        
        NSLog(@"JSON: %@", responseObject);
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Completed!", nil)];
        
        //this code will be as it is
        [ORDER removeOrder:_orderIdentifier];
        [ORDER setLastOrderTime:[NSDate date]];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You!", nil) message:NSLocalizedString(@"Order placed successfully.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:error.localizedDescription duration:1.0f position:@"top"];
    }];
}*/

- (void) manageRemoving : (NSString *) orderIdentifier {
    [ORDER removeOrder:orderIdentifier];
    [_failedOrderDictionary removeObjectForKey:orderIdentifier];
    if (_failedOrderDictionary.allKeys.count)
        [self makePayment:_failedOrderDictionary.allKeys.lastObject];
}

- (void) getMemberShipType {
    // [SVProgressHUD showWithStatus:NSLocalizedString(@"Setting Up!", nil) maskType:SVProgressHUDMaskTypeGradient];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[WSMANAGER URLfor:WSRequestGetMemberShipType]
      parameters:@{@"timestamp":@""}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"responseObject = %@", responseObject);
             if ([responseObject[@"status"] integerValue] == 1) {
                 //            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done!", nil)];
                 [USER saveMemberShipTypes:responseObject[@"membership_type"]];
             }else{
                 //[self showMembershiploadingFailedAlert];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error.localizedDescription = %@", error.localizedDescription);
             [SVProgressHUD dismiss];
             //[self showMembershiploadingFailedAlert];
         }];
}

@end