//
//  CircleProgressView2.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/7.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "CircleProgressView2.h"

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define  PROGREESS_WIDTH 80 //圆直径
#define PROGRESS_LINE_WIDTH 4 //弧线的宽度
@interface CircleProgressView2 ()

@property (nonatomic,strong) CAShapeLayer *trackLayer;
@property (nonatomic,strong) CAShapeLayer *progressLayer;

@end


@implementation CircleProgressView2


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:(PROGREESS_WIDTH-PROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(-210) endAngle:degreesToRadians(30) clockwise:YES];
        
        
        
        _trackLayer = [CAShapeLayer layer];//创建一个track shape layer
        _trackLayer.frame = self.bounds;
        [self.layer addSublayer:_trackLayer];
        _trackLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer.strokeColor = [[UIColor grayColor] CGColor];//指定path的渲染颜色
        _trackLayer.opacity = 0.25; //背景同学你就甘心做背景吧，不要太明显了，透明度小一点
        _trackLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
        _trackLayer.lineWidth = PROGRESS_LINE_WIDTH;//线的宽度
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:(PROGREESS_WIDTH-PROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(-210) endAngle:degreesToRadians(30) clockwise:YES];//上面说明过了用来构建圆形
        _trackLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
        
        
        
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor  = [[UIColor cyanColor] CGColor];
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = PROGRESS_LINE_WIDTH;
        _progressLayer.path = [path CGPath];
//        _progressLayer.strokeEnd = 0;
_progressLayer.strokeStart = 0.f;
        _progressLayer.strokeEnd = 1.f;

        
        CALayer *gradientLayer = [CALayer layer];
        CAGradientLayer *gradientLayer1 =  [CAGradientLayer layer];
        gradientLayer1.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
        [gradientLayer1 setColors:[NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor],(id)[[UIColor yellowColor] CGColor], nil]];
//        [gradientLayer1 setLocations:@[@0.5,@0.9,@1 ]];
//        [gradientLayer1 setStartPoint:CGPointMake(0.5, 1)];
//        [gradientLayer1 setEndPoint:CGPointMake(0.5, 0)];
        [gradientLayer addSublayer:gradientLayer1];
        
//        CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
//        [gradientLayer2 setLocations:@[@0.1,@0.5,@1]];
//        gradientLayer2.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
//        [gradientLayer2 setColors:[NSArray arrayWithObjects:(id)[[UIColor yellowColor] CGColor],(id)[[UIColor purpleColor] CGColor], nil]];
//        [gradientLayer2 setStartPoint:CGPointMake(0.5, 0)];
//        [gradientLayer2 setEndPoint:CGPointMake(0.5, 1)];
//        [gradientLayer addSublayer:gradientLayer2];
        
        
        
        [gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
        [self.layer addSublayer:gradientLayer];
    }
    return self;
}

@end
