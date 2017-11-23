//
//  PNCProgressHUD.h
//  MBProgressHUD
//
//  Created by hzpnc on 16/3/26.
//  Copyright © 2016年 lanouhn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNCProgressHUD : UIView

@property CGAffineTransform rotationTransform;


+ (PNCProgressHUD *)showHUDAddedTo:(UIView *)view;

+ (BOOL)hideHUDForView:(UIView *)view;

- (id)initWithView:(UIView *)view;

+ (void)showTitle:(NSString *)title toView:(UIView *)view;

+ (void)showHUD;

+ (void)hideHUD;

+ (void)showNoHUD;

@end
