//
//  PNCDialogView.m
//  Project61
//
//  Created by hzpnc on 15/7/8.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "PNCDialogView.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

#define kTopCircleViewRadius        70

#define kTopTransParentViewHeight   kTopCircleViewRadius / 2

@implementation PNCDialogView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        
        self.topTransparentView = [[UIView alloc] init];
        self.topCircleView = [[UIView alloc] init];
        self.containerView = [[UIView alloc] init];
        self.spliter = [[UIView alloc] init];
        
        [self addSubview:self.topTransparentView];
        [self addSubview:self.containerView];
        [self addSubview:self.topCircleView];
        [self addSubview:self.spliter];
        
        self.topCircleView.backgroundColor = [UIColor colorFromHexString:@"#47a8ef"];
        self.topCircleView.backgroundColor = [UIColor clearColor];
        
        self.topCircleView.layer.cornerRadius = kTopCircleViewRadius / 2;
        
        
        self.topTransparentView.layer.opacity = 0.0f;
        
        self.containerView.backgroundColor = WhiteColor;
        self.containerView.layer.cornerRadius = 5;
        
        self.spliter.backgroundColor = [UIColor blackColor];
        self.spliter.layer.opacity = 0.2;
        
        return self;
    }
    return nil;
}

- (void)layoutSubviews {
//    [self.topTransparentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(self.mas_width);
//        make.height.mas_equalTo(kTopTransParentViewHeight);
//        make.top.mas_equalTo(self.mas_top);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//    }];
    [super layoutSubviews];

    
//    [self.topCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(kTopCircleViewRadius);
//        make.height.mas_equalTo(kTopCircleViewRadius);
//        make.top.mas_equalTo(self.mas_top);
//        make.centerX.mas_equalTo(self.mas_centerX);
//    }];
    
//    [self.spliter mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(self.mas_width);
//        make.height.mas_equalTo(0.5);
//        make.left.mas_equalTo(self.mas_left);
//        make.top.mas_equalTo(self.topCircleView.mas_bottom).with.offset(10);
//    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width);
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];

}

@end
