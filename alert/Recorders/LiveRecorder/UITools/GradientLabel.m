//
//  GradientLabel.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/6.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "GradientLabel.h"

@implementation GradientLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc]init];
        self.label = label;
        [self addSubview:label];             
    }
    return self;
}

- (void)setGradientLayerColor:(NSString*)color {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0, .5);
    gradientLayer.endPoint = CGPointMake(1, .5);

    
    NSArray *b = [color componentsSeparatedByString:@"&"];
    if (b.count == 1) {
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorFromHexString:color].CGColor,
                                [UIColor colorFromHexString:color].CGColor,
                                nil];

    } else {
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorFromHexString:b[0]].CGColor,
                           [UIColor colorFromHexString:b[1]].CGColor,
                           nil];
    }
    self.gradientLayer = gradientLayer;
    [self.layer addSublayer:gradientLayer];
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 设置其尺寸.
    CGRect temp = self.label.frame;
    temp.size.width = self.frame.size.width;
    self.label.frame = temp;
    [self.label sizeToFit];
    self.label.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    self.gradientLayer.frame = self.label.frame;
    
    // mask层工作原理:按照透明度裁剪，只保留非透明部分，文字就是非透明的，因此除了文字，其他都被裁剪掉，这样就只会显示文字下面渐变层的内容，相当于留了文字的区域，让渐变层去填充文字的颜色。
    // 设置渐变层的裁剪层
    self.gradientLayer.mask = self.label.layer;
    
    // 注意:一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层，这样做的目的：以渐变层为坐标系，方便计算裁剪区域，如果以其他层为坐标系，还需要做点的转换，需要把别的坐标系上的点，转换成自己坐标系上点，判断当前点在不在裁剪范围内，比较麻烦。
    // 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域。
    self.label.frame = self.gradientLayer.bounds;
}

@end
