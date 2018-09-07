//
//  Theme.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "Theme.h"


@implementation CCThemeTableViewCell
- (void) awakeFromNib {
    [self setSelectedBackgroundView];
}

- (id) init {
    if (self = [super init]) {
        [self setSelectedBackgroundView];
    }
    return self;
}


- (void) setSelectedBackgroundView {
    UIView *selectedBgView = [[UIView alloc] initWithFrame:self.frame];
    [selectedBgView setBackgroundColor:[Theme themeColor]];
    [self setSelectedBackgroundView:selectedBgView];
}
@end

@implementation CCTemeRoundCornerView : UIView
- (void) awakeFromNib {
    [self setCornerEdge];
}

- (id) init {
    if (self = [super init]) {
        [self setCornerEdge];
    }
    return self;
}

- (void) setCornerEdge{
    self.layer.cornerRadius = 6.0f;
    self.layer.masksToBounds = YES;
}

@end

@implementation CCTemeRoundCornerButton : UIButton
- (void) awakeFromNib {
    [self setCornerEdge];
}

- (id) init {
    if (self = [super init]) {
        [self setCornerEdge];
    }
    return self;
}

- (void) setCornerEdge{
    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = YES;
}

@end

@implementation CCThemeButton
- (void) awakeFromNib {
    [self setUIProperties];
}

- (id) init {
    if (self = [super init]) {
        [self setUIProperties];
    }
    return self;
}

- (void) setUIProperties{
    //set corner edge
    [super setCornerEdge];
    
    //border
    [self.layer setBorderColor:[Theme textNormalColor].CGColor];
    [self.layer setBorderWidth:1.0f];

    //color adjust ment
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.4f]];
    [self setTitleColor:[Theme textNormalColor] forState:UIControlStateNormal];
    [self setTitleColor:[Theme textHilightedColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[Theme textHilightedColor] forState:UIControlStateSelected];
}

@end


@implementation CCTextField : UITextField

- (void) awakeFromNib {
    [self setDefaultFont];
}

- (id) init {
    if (self = [super init]) {
        [self setDefaultFont];
    }
    return self;
}

- (void) setDefaultFont {
//    [self setFont:[Theme applicationFont:FontPropertyDefault ofSize:[self font].pointSize]];
    [self setFont:[UIFont systemFontOfSize:[self font].pointSize]];
}

- (void) setApplicationFontOfSize : (CGFloat) size {
    [self setFont:[Theme applicationFont:FontPropertyDefault ofSize:size]];
}

- (void) setItalicApplicationFontOfSize : (CGFloat) size {
    [self setFont:[Theme applicationFont:FontPropertyDefaultItalic ofSize:size]];
}

@end

@implementation CCLabel

- (void) awakeFromNib {
    [self setDefaultProperties];
}

- (id) init {
    if (self = [super init]) {
        [self setDefaultProperties];
    }
    return self;
}

- (void) setDefaultProperties {
    [self setDefaultFont];
    self.textColor = [Theme textNormalColor];
}

- (void) setDefaultFont {
    [self setFont:[Theme applicationFont:FontPropertyDefault ofSize:[self font].pointSize]];
}

- (void) setApplicationFontOfSize : (CGFloat) size {
    [self setFont:[Theme applicationFont:FontPropertyDefault ofSize:size]];
}

- (void) setItalicApplicationFontOfSize : (CGFloat) size {
    [self setFont:[Theme applicationFont:FontPropertyDefaultItalic ofSize:size]];
}

@end


@implementation Theme

#pragma mark - Color
//color
+ (UIColor *) themeColor {
    return [UIColor colorWithRed:251.0f/255.0f green:176.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
}

+ (UIColor *) themeBGColor {
//    return [UIColor colorWithRed:253.0f/234.0f green:234.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"app_bg"]];
//    return [UIColor orangeColor];
}

+ (UIColor *) themeNavbarColor {
//    return [UIColor colorWithRed:247.0f/234.0f green:244.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_gradient"]];
}

+ (UIColor *) textNormalColor {
    return [UIColor colorWithRed:237.0f/234.0f green:220.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
}

+ (UIColor *) textHilightedColor {
    return [UIColor colorWithRed:247.0f/234.0f green:189.0f/255.0f blue:93.0f/255.0f alpha:1.0f];
}




#pragma mark - Font
//
+ (NSString *) applicationFontName : (FontProperty) property {
    switch (property) {
        case FontPropertyBlack:
            return @"Gotham-Black.otf";
            
        case FontPropertyBlackItalic:
            return @"Gotham-BlackItalic.otf";
            
        case FontPropertyBold:
            return @"Gotham-Bold.otf";
            
        case FontPropertyBoldItalic:
            return @"Gotham-BoldItalic.otf";
            
        case FontPropertyLight:
            return @"Gotham-Light.otf";
            
        case FontPropertyLightItalic:
            return @"Gotham-LightItalic.otf";
            
        case FontPropertyMedium:
            return @"Gotham-Medium.otf";

        case FontPropertyMediumItalic:
            return @"Gotham-MediumItalic.otf";

        case FontPropertyThin:
            return @"Gotham-Thin.otf";

        case FontPropertyThinItalic:
            return @"Gotham-ThinItalic.otf";
            
        case FontPropertyUltra:
            return @"Gotham-Ultra.otf";
            
        case FontPropertyUltraItalic:
            return @"Gotham-UltraItalic.otf";
            
        case FontPropertyXLight:
            return @"Gotham-XLight.otf";
            
        case FontPropertyXLightItalic:
            return @"Gotham-XLightItalic.otf";
            
        case FontPropertyDefaultItalic:
            return @"Gotham-BookItalic.otf";
            
        default:
            break;
    }
    return @"Gotham-Book.otf";
}

//
+ (UIFont *) applicationFont :(FontProperty) property ofSize : (CGFloat) size {
    [UIFont boldSystemFontOfSize:14.0f];
    return [UIFont fontWithName:[Theme applicationFontName:property] size:size];
}

@end
