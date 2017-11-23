//
//  DropdownMuneTableViewCell.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/6/2.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "DropdownMuneTableViewCell.h"

@implementation DropdownMuneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.colorView];
        [self.contentView addSubview:self.colorCount];
        [self.contentView addSubview:self.colorNameLabel];
    }
    return self;
}

- (UILabel *)colorCount {
    if (!_colorCount) {
        _colorCount = [UILabel new];
        _colorCount.font = [UIFont systemFontOfSize:18 * ADJUSTWIDTH];
        _colorCount.text = @"0";
        _colorCount.textColor = c_cccccc;
    }
    return _colorCount;
}

- (UILabel *)colorNameLabel {
    if (!_colorNameLabel) {
        _colorNameLabel = [UILabel new];
        _colorNameLabel.font = [UIFont systemFontOfSize:18 * ADJUSTWIDTH];
        _colorNameLabel.text = @"未分组";
        _colorNameLabel.textColor = c_cccccc;
    }
    return _colorNameLabel;
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [UIView new];
        _colorView.backgroundColor = c_cccccc;
    }
    return _colorView;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + 1);
    CGContextSetLineWidth(context, 0.5);
    [c_e0e0e0 set];
    CGContextStrokePath(context);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(70 * ADJUSTWIDTH);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(20 * ADJUSTWIDTH);
        make.width.mas_equalTo(33 * ADJUSTWIDTH);
    }];
    
    [self.colorNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.colorView.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(self.colorNameLabel.mas_height);
        make.width.mas_equalTo(self.colorNameLabel.mas_width);
    }];
    
    [self.colorCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(-70 * ADJUSTWIDTH);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(self.colorCount.mas_height);
        make.width.mas_equalTo(self.colorCount.mas_width);
    }];
}

@end
