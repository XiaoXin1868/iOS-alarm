//
//  CCHomeTableViewController.h
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
}

@property (nonatomic, retain) NSString *mTitle;
@property (nonatomic, retain) NSString *mSubTitle;
-(id)initWithLocation:(CLLocationCoordinate2D)location withTitle:(NSString *)title withSubTitle:(NSString *)subTitle withImage:(UIImage *)locationImage;
@end


@interface CCHomeTableViewController : UITableViewController

@end
