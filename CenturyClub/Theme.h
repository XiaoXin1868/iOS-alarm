//
//  Theme.h
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    FontPropertyBlack,
    FontPropertyBlackItalic,
    FontPropertyBold,
    FontPropertyBoldItalic,
    FontPropertyLight,
    FontPropertyLightItalic,
    FontPropertyMedium,
    FontPropertyMediumItalic,
    FontPropertyThin,
    FontPropertyThinItalic,
    FontPropertyUltra,
    FontPropertyUltraItalic,
    FontPropertyXLight,
    FontPropertyXLightItalic,
    FontPropertyDefault,
    FontPropertyDefaultItalic,
}FontProperty;

@interface CCThemeTableViewCell : UITableViewCell
- (void) setSelectedBackgroundView;
@end

@interface CCTemeRoundCornerView : UIView
@end



@interface CCTemeRoundCornerButton : UIButton
@end

@interface CCThemeButton : CCTemeRoundCornerButton

@end


@interface CCTextField : UITextField
- (void) setDefaultFont;
- (void) setApplicationFontOfSize : (CGFloat) size;
- (void) setItalicApplicationFontOfSize : (CGFloat) size;
@end


@interface CCLabel : UILabel
- (void) setDefaultFont;
- (void) setApplicationFontOfSize : (CGFloat) size;
- (void) setItalicApplicationFontOfSize : (CGFloat) size;
@end

@interface Theme : NSObject

//color
+ (UIColor *) themeColor;
+ (UIColor *) themeBGColor;
+ (UIColor *) themeNavbarColor;
+ (UIColor *) textNormalColor;
+ (UIColor *) textHilightedColor;


//font
+ (NSString *) applicationFontName : (FontProperty) property;
+ (UIFont *) applicationFont :(FontProperty) property ofSize : (CGFloat) size;

@end
