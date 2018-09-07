//
//  PinViewController.m
//  CenturyClub
//
//  Created by Developer on 06/07/15.
//  Copyright (c) 2015 centuryclub. All rights reserved.
//

#import "PinViewController.h"

@interface PinViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *pinDotContainerView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *pinDotViews;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberPadButtons;
@property (weak, nonatomic) IBOutlet UILabel *pinInformationLabel;

@property (strong, nonatomic) NSString *pinString;
@property (nonatomic, strong) NSString *currentPin;
@property (nonatomic, strong) NSString *tempPin;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation PinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    [self setUserInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_pinInformationLabel setHidden:YES];
}

#pragma mark - Support
- (void) setDelegate:(id<PinViewControllerDelegate>)delegate {
    //set delegate
    _delegate = delegate;
    
    //initialize
    _currentPin = [_delegate getCurrentPin:self];
    _tempPin = @"";
    _pinString = @"";
    
    //set UI according to data
    if ([self settingNewPin]) {
        [_pinInformationLabel setHidden:NO];
        _pinInformationLabel.text = NSLocalizedString(@"Type Pin", nil);
    }else{
        [_pinInformationLabel setHidden:YES];
    }
}

- (BOOL) settingNewPin {
    return (_currentPin == nil || _currentPin.length == 0);
}

#pragma mark - Create and Manage PIN UI
- (void) setUserInterface {
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
    int i = 0;
    for (UIButton *button in _numberPadButtons) {
        [button setTitle:[@(i) stringValue] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(numberpadButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [button.layer setCornerRadius:40.0f];
        [button.layer setBorderColor:[UIColor whiteColor].CGColor];
        [button.layer setBorderWidth:1.0f];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
        i++;
    }
    
    //
    [self clearDotView];

    //
    [_cancelButton.layer setCornerRadius:_cancelButton.frame.size.width / 2];
    [_cancelButton.layer setMasksToBounds:YES];
    [_cancelButton.layer setBorderWidth:1.0f];
    [_cancelButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [_buttonContainerView setBackgroundColor:[UIColor clearColor]];
    [_pinDotContainerView setBackgroundColor:[UIColor clearColor]];
    [_containerView setBackgroundColor:[UIColor clearColor]];
}

- (void) clearDotView {
    int i = 0;
    for (UIView *view in _pinDotViews) {
        view.tag = i;
        [UIView animateWithDuration:0.4f animations:^{
            [view setBackgroundColor:[UIColor clearColor]];
            [view.layer setBorderColor:[UIColor whiteColor].CGColor];
        }];
        [view.layer setBorderWidth:1.0f];
        [view.layer setCornerRadius:10.0f];
        [view.layer setMasksToBounds:YES];
        i++;
    }
}

- (void) animateNod : (UIView *) view {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([view center].x - 5.0f, [view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([view center].x + 5.0f, [view center].y)]];
    [[view layer] addAnimation:animation forKey:@"position"];
    
//    //set data
//    CGPoint baseCenter = view.center;
//    CGPoint leftCenter = baseCenter;
//    leftCenter.x = baseCenter.x - 5;
//    CGPoint rigthCenter = baseCenter;
//    rigthCenter.x = baseCenter.x + 5;
//
//    //start animating
//    [UIView animateKeyframesWithDuration:1.0
//                                   delay:0.0
//                                 options:UIViewKeyframeAnimationOptionAutoreverse
//                              animations:^{
//                                  [UIView addKeyframeWithRelativeStartTime:0.0
//                                                          relativeDuration:0.05
//                                                                animations:^{
//                                                                    view.center = leftCenter;
//                                                                }];
//                                  [UIView addKeyframeWithRelativeStartTime:0.05
//                                                          relativeDuration:0.05
//                                                                animations:^{
//                                                                    view.center = rigthCenter;
//                                                                }];
//                              } completion:^(BOOL finished) {
//                                  view.center = baseCenter;
//                              }];
    
}

- (void) numberpadButtonTouched : (id) sender {
    UIButton *button = (UIButton *) sender;
    if (_pinString.length < 4) {
        _pinString = [_pinString stringByAppendingString:[@(button.tag) stringValue]];
        [UIView animateWithDuration:0.3f animations:^{
            UIView *view = _pinDotViews[_pinString.length-1];
            [view setBackgroundColor:[UIColor whiteColor]];
        }];
    }
    [self performSelector:@selector(pinStringChanged:) withObject:_pinString afterDelay:0.6f];
}

- (void) pinStringChanged : (NSString *) pinString {
    if (pinString.length != 4)
        return;
    
    //
    [self clearDotView];//clear all dots
    
    //
    if ([self settingNewPin]) {//setting new pin
        if (_tempPin == nil || _tempPin.length < 4) {
            _pinInformationLabel.text = NSLocalizedString(@"Retype pin", nil);
            _tempPin = _pinString;
            _pinString = @"";
        }else if([_tempPin isEqualToString:_pinString]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate pinController:self pin:_pinString withStatus:PinStatusCreated];
            }];
        }else{
            [self animateNod:_pinDotContainerView];
            _pinInformationLabel.text = NSLocalizedString(@"Type pin", nil);
            _tempPin = @"";
            _pinString = @"";
        }
    }else{
        if ([_currentPin isEqualToString:_pinString]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate pinController:self pin:_pinString withStatus:PinStatusMatched];
            }];
        }else{
            [self animateNod:_pinDotContainerView];
        }
        _tempPin = @"";
        _pinString = @"";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cancelButtonTouched:(id)sender {
    [_delegate pinController:self pin:nil withStatus:PinStatusNone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end