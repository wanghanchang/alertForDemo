//
//  GradientLayer.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/6.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "GradientLayer.h"
#import <UIKit/UIKit.h>

@implementation GradientLayer

+ (CAGradientLayer*)getMyGradientLayerBySize:(CGSize)size targetStr:(NSString*)colorStr {
    NSArray *b = [colorStr componentsSeparatedByString:@"&"];
        if (b.count == 1) {
            return nil;
        } else {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.startPoint = CGPointMake(0, .5);
            gradient.endPoint = CGPointMake(1, .5);
            gradient.frame = CGRectMake(0, 0, size.width, size.height);
            gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorFromHexString:b[0]].CGColor,
                                [UIColor colorFromHexString:b[1]].CGColor,
                                nil];
            return gradient;
        }
}



@end
