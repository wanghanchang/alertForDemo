//
//  IconLoginView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/25.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "IconLoginView.h"

@implementation IconLoginView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.topImg];
        [self addSubview:self.downLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.topImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(50 * ADJUSTHEIGHT);
        make.height.mas_equalTo(50 * ADJUSTHEIGHT);
    }];
    
    [self.downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImg.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.topImg.mas_centerX);
        make.height.mas_equalTo(self.downLabel);
        make.width.mas_equalTo(self.downLabel);
    }];
    _topImg.layer.cornerRadius = self.topImg.frame.size.width / 2;
    _topImg.layer.masksToBounds = YES;
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] init];
    }
    return _topImg;
}

- (UILabel *)downLabel {
    if (!_downLabel) {
        _downLabel = [UILabel new];
        _downLabel.font = [UIFont systemFontOfSize:12.0];
        _downLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _downLabel;
}

@end
