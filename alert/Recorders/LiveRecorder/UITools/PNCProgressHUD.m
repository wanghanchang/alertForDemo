//
//  PNCProgressHUD.m
//  MBProgressHUD
//
//  Created by hzpnc on 16/3/26.
//  Copyright © 2016年 lanouhn. All rights reserved.
//
#define RADIANS(degrees) ((degrees * (float)M_PI) / 180.0f)


#import "PNCProgressHUD.h"
#import <UIImage+GIF.h>

@interface PNCProgressHUD ()

@property (nonatomic, strong) UIImageView *myImage;

@property (nonatomic, strong) UIImageView *myBlackImage;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) UIView *backView;

@end

@implementation PNCProgressHUD

+ (PNCProgressHUD *)showHUDAddedTo:(UIView *)view{
    
    if (view == nil) {
        view = (UIView*)[[[UIApplication sharedApplication]delegate]window];
    }
    PNCProgressHUD *hud = [[PNCProgressHUD alloc] initWithView:view];
    hud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [hud addSubview:hud.myImage];
    [view addSubview:hud];
    return hud;
}

+ (void)showHUD {
    UIView *view = (UIView*)[[[UIApplication sharedApplication]delegate]window];
    PNCProgressHUD *hud = [[PNCProgressHUD alloc] initWithView:view];
    hud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [hud addSubview:hud.myImage];
    [view addSubview:hud];
}



+ (void)showNoHUD {
    UIView *view = (UIView*)[[[UIApplication sharedApplication]delegate]window];
    PNCProgressHUD *hud = [[PNCProgressHUD alloc] initWithView:view];
    hud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [hud addSubview:hud.myBlackImage];
    [view addSubview:hud];
}


+ (void)hideHUD {
    UIView *viewToRemove = nil;
    UIView *view = (UIView*)[[[UIApplication sharedApplication]delegate]window];
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[PNCProgressHUD class]]) {
            viewToRemove = v;
        }
    }

    PNCProgressHUD *HUD = (PNCProgressHUD *)viewToRemove;
    if (HUD) {
        [HUD removeFromSuperview];
    }
}

+ (void)showTitle:(NSString *)title toView:(UIView *)view {
    if (view == nil) {
        view = (UIView*)[[[UIApplication sharedApplication]delegate]window];
    }
    PNCProgressHUD *hud = [[PNCProgressHUD alloc] initWithView:view];
    hud.backgroundColor = [UIColor clearColor];
    [hud addSubview:hud.backView];
    hud.myLabel.text = title;
    [hud addSubview:hud.myLabel];
    [hud.timer fire];
    [view addSubview:hud];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PNCProgressHUD hideHUDForView:view];
    });
}


+ (BOOL)hideHUDForView:(UIView *)view {
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[PNCProgressHUD class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        PNCProgressHUD *HUD = (PNCProgressHUD *)viewToRemove;
        [HUD removeFromSuperview];
        [HUD.timer invalidate];
        return YES;
    } else {
        return NO;
    }
}

- (id)initWithView:(UIView *)view {
    // Let's check if the view is nil (this is a common error when using the windw initializer above)
    if (!view) {
        [NSException raise:@"MBProgressHUDViewIsNillException"
                    format:@"The view used in the MBProgressHUD initializer is nil."];
    }
    id me = [self initWithFrame:view.bounds];
    // We need to take care of rotation ourselfs if we're adding the HUD to a window
    if ([view isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:NO];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return me;
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSInteger degrees = 0;
    
    // Stay in sync with the superview
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { degrees = -90; }
        else { degrees = 90; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { degrees = 180; }
        else { degrees = 0; }
    }
    
    _rotationTransform = CGAffineTransformMakeRotation(RADIANS(degrees));
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    [self setTransform:_rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
}

- (NSTimer *)timer {
    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(rotatePlayImageView) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (UIImageView *)myBlackImage {
    if (!_myBlackImage) {
        _myBlackImage = [[UIImageView alloc] init];
        _myBlackImage.bounds = CGRectMake(0, 0, 40, 40);
        _myBlackImage.center = self.center;
    }
    return _myBlackImage;
}

- (UIImageView *)myImage {
    if (!_myImage) {
        self.myImage = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"myProgress"]];
        self.myImage.bounds = CGRectMake(0, 0, 40, 40);
        self.myImage.center = self.center;
    }
    return _myImage;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.bounds = CGRectMake(0, 0, 100, 100);
        _backView.center = self.center;
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }
    return _backView;
}

- (UILabel *)myLabel {
    if (!_myLabel) {
        _myLabel = [[UILabel alloc] init];
        _myLabel.textAlignment = NSTextAlignmentCenter;
        _myLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        _myLabel.font = [UIFont systemFontOfSize:16];
        _myLabel.bounds = CGRectMake(0, 0, 100, 50);
        _myLabel.center = self.center;
    }
    return _myLabel;
}

//图片转起来
- (void)rotatePlayImageView {
    self.myImage.transform = CGAffineTransformRotate(self.myImage.transform, 0.3);
    
    
}
@end
