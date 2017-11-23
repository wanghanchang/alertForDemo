//
//  CircleProgressView.m
//  CircleProgress
//
//  Created by ln on 15/8/4.
//  Copyright (c) 2015年 xcgdb. All rights reserved.
//

#import "CircleProgressView.h"

#define kLineWidth 8

@interface CircleProgressView()
@property (nonatomic,strong) CAShapeLayer *outLayer;
@property (nonatomic,strong) CAShapeLayer *progressLayer;

@property (nonatomic,strong) CAGradientLayer *gradientLayer;
@end

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGRect frame = self.frame;
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        self.progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.progressLabel.font = [UIFont systemFontOfSize:12.0];
        self.progressLabel.text = @"0%";
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.progressLabel];
        
        
        self.outLayer = [CAShapeLayer layer];
        CGRect rect = {kLineWidth / 2, kLineWidth / 2,
            frame.size.width - kLineWidth, frame.size.height - kLineWidth};
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        _outLayer.frame = self.bounds;
        self.outLayer.strokeColor = [UIColor colorFromHexString:@"#E6E6E6"].CGColor;
        self.outLayer.lineWidth = kLineWidth;
        self.outLayer.fillColor =  [UIColor clearColor].CGColor;
        self.outLayer.lineCap = kCALineCapRound;
        self.outLayer.path = path.CGPath;
        self.outLayer.strokeStart = 0.f;
        self.outLayer.strokeEnd = 1.f;
        [self.layer addSublayer:self.outLayer];

        self.progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor colorFromHexString:@"#E6E6E6"].CGColor;
        self.progressLayer.lineWidth = kLineWidth;
        self.progressLayer.lineCap = kCALineCapRound;
        self.progressLayer.path = path.CGPath;
        self.progressLayer.strokeStart = 0.f;
        self.progressLayer.strokeEnd = 0.f;
        
        CALayer *myLayer = [CALayer layer];     
        self.gradientLayer =  [CAGradientLayer layer];
        self.gradientLayer.frame = self.bounds;
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorFromHexString:@"#ff8519"] CGColor],(id)[[UIColor colorFromHexString:@"#fc3932"] CGColor],nil];
//        [self.gradientLayer setLocations:@[@0.5,@0.9,@1 ]];
        
        
        [self.gradientLayer setStartPoint:CGPointMake(0.5, 0)];
        [self.gradientLayer setEndPoint:CGPointMake(0.5, 1.0)];
//
        [myLayer addSublayer:self.gradientLayer];
        myLayer.mask = self.progressLayer;
        [self.layer addSublayer:myLayer];
        
//        
//        [self.layer addSublayer:self.progressLayer];
        
//        CGRect temp = self.label.frame;
//        temp.size.width = self.frame.size.width;
//        self.label.frame = temp;
//        [self.label sizeToFit];
//        self.label.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
//        self.gradientLayer.frame = self.label.frame;
        
        // mask层工作原理:按照透明度裁剪，只保留非透明部分，文字就是非透明的，因此除了文字，其他都被裁剪掉，这样就只会显示文字下面渐变层的内容，相当于留了文字的区域，让渐变层去填充文字的颜色。
        // 设置渐变层的裁剪层
//        self.gradientLayer.mask = self.label.layer;
        // 注意:一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层，这样做的目的：以渐变层为坐标系，方便计算裁剪区域，如果以其他层为坐标系，还需要做点的转换，需要把别的坐标系上的点，转换成自己坐标系上点，判断当前点在不在裁剪范围内，比较麻烦。
        // 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域。
//        self.label.frame = self.gradientLayer.bounds;

        
        
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.progressLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    return self;

}

- (void)updateProgressWithNumber:(float)number {
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.5];
    self.progressLayer.strokeEnd =  number;
    self.progressLabel.text = [NSString stringWithFormat:@"%.f%%",number * 100];
    [CATransaction commit];
}

@end

