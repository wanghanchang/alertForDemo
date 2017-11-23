//
//  GradientLabel.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/6.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientLabel : UIView

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) CAGradientLayer *gradientLayer;
- (instancetype)initWithFrame:(CGRect)frame;
- (void) setGradientLayerColor:(NSString*)color;
@end
