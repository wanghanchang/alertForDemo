

//
//  HXDialog.m
//  alert
//
//  Created by 匹诺曹 on 2017/11/12.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "HXDialog.h"

@implementation HXDialog

- (void)hideWithinSecond:(CGFloat)seconds after:(CGFloat)scs {
    CGSize screenSize = [self countScreenSize];
    self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    CGSize contentSize = self.contentView.frame.size;
    
    self.contentView.frame = CGRectMake(0.6 * (screenSize.width - contentSize.width), 0.4 * (screenSize.height - contentSize.height),
                                        contentSize.width, contentSize.height / 10 * 7);
    
    
    [self addSubview:self.contentView];
    
    for (UIView *view in [[[UIApplication sharedApplication] windows] firstObject].subviews) {
        if ([view isKindOfClass:self.class]) {
            [view removeFromSuperview];
        }
    }
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    self.contentView.layer.opacity = 0.5f;
    self.contentView.layer.transform = CATransform3DMakeScale(0.5f, 0.5f, 1.0);
    
    CATransform3D currentTransform = self.contentView.layer.transform;
    [UIView animateWithDuration:0.2f delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.layer.opacity = 1.0f;
                         self.contentView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0);
                         [UIView animateWithDuration:seconds delay:scs  options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.backgroundColor = [UIColor clearColor];
                                              self.contentView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.5f, 1.0f, 1.0));
                                              self.contentView.layer.opacity = 0.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  [obj removeFromSuperview];
                                              }];
                                              [self removeFromSuperview];
                                          }
                          ];
                     }
                     completion:NULL
     ];
}

- (void)show {
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    
    CGSize screenSize = [self countScreenSize];
    self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    CGSize contentSize = self.contentView.frame.size;
    
    self.contentView.frame = CGRectMake(0.5 * (screenSize.width - contentSize.width), 0.5 * (screenSize.height - contentSize.height),
                                        contentSize.width, contentSize.height / 10 * 7);
    
    [self addSubview:self.contentView];
    
    for (UIView *view in [[[UIApplication sharedApplication] windows] firstObject].subviews) {
        if ([view isKindOfClass:self.class]) {
            [view removeFromSuperview];
        }
    }
    
    //    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    //    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    [frontView addSubview:self];
    
    self.contentView.layer.opacity = 0.5f;
    self.contentView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.layer.opacity = 1.0f;
                         self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}

- (void)hide {
    CATransform3D currentTransform = self.contentView.layer.transform;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor clearColor];
                         self.contentView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.contentView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                             [obj removeFromSuperview];
                         }];
                         [self removeFromSuperview];
                     }
     ];
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)onTap {
    if(self.hideWhenTouchUpOutside) {
        [self hide];
    }
}


@end
