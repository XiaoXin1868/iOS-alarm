//
//  PatternLockMattricsView.m
//  CenturyClub
//
//  Created by Developer on 01/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "PatternLockMattricsView.h"
#import "DrawPatternLockView.h"
#define MATRIX_SIZE 2

@interface PatternLockMattricsView()
@property (nonatomic, strong) DrawPatternLockView *drawPatternView;
@end

@implementation PatternLockMattricsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) awakeFromNib {
    DrawPatternLockView *view = [[DrawPatternLockView alloc] init];
    _drawPatternView = view;
    view = nil;
    [self addSubview:_drawPatternView];
    self.backgroundColor = [UIColor clearColor];
    
    for (int i=0; i<MATRIX_SIZE; i++) {
        for (int j=0; j<MATRIX_SIZE; j++) {
            UIImage *dotImage = [UIImage imageNamed:@"swipe_dot"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:dotImage
                                                       highlightedImage:[UIImage imageNamed:@"swipe_dot_selected"]];
            [imageView setContentMode:UIViewContentModeCenter];
            imageView.frame = CGRectMake(0, 0, dotImage.size.width+40, dotImage.size.height+40);
            imageView.userInteractionEnabled = YES;
            imageView.tag = j*MATRIX_SIZE + i + 1;
            [self addSubview:imageView];
        }
    }
    
    //
    [self layoutSubviews];
}

- (UIImageView *) getArrowImageView : (int) i :(int) j {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizontal_arrow"]];
    if (i == 0 && j == 0) {
        return imageView;
    }else if (i == 0 && j == 0) {
        return imageView;
    }

    return nil;
}


- (void) layoutSubviews {
    int w = self.frame.size.width/MATRIX_SIZE;
    int h = self.frame.size.height/MATRIX_SIZE;
    
    int i=0;
    for (UIView *view in self.subviews) 
        if ([view isKindOfClass:[UIImageView class]]) {
            int x = w*(i/MATRIX_SIZE) + w/2;
            int y = h*(i%MATRIX_SIZE) + h/2;
            view.center = CGPointMake(x, y);
            i++;
        }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate patternDrawingStarted:nil];
    _paths = [[NSMutableArray alloc] init];
}



- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    UIView *touched = [self hitTest:pt withEvent:event];
    
    [_drawPatternView drawLineFromLastDotTo:pt];
    
    if (touched!=self) {
        NSLog(@"touched view tag: %zd ", touched.tag);
        
        BOOL found = NO;
        for (NSNumber *tag in _paths) {
            found = tag.integerValue==touched.tag;
            if (found)
                break;
        }
        
        if (found)
            return;
        
        [_paths addObject:[NSNumber numberWithInteger:touched.tag]];
        [_drawPatternView addDotView:touched];
        
        UIImageView* iv = (UIImageView*)touched;
        iv.highlighted = YES;
    }
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // clear up hilite
    [_drawPatternView clearDotViews];
    
    for (UIView *view in self.subviews)
        if ([view isKindOfClass:[UIImageView class]])
            [(UIImageView*)view setHighlighted:NO];
    
    [self setNeedsDisplay];
    
    // pass the output to target action...
    [_delegate patternDrawingFinished:[self getKey]];
}


// get key from the pattern drawn
// replace this method with your own key-generation algorithm
- (NSString*)getKey {
    NSMutableString *key;
    key = [NSMutableString string];
    
    // simple way to generate a key
    for (NSNumber *tag in _paths) {
        [key appendFormat:@"%02zd", tag.integerValue];
    }
    
    return key;
}

@end
