//
//  GradientLayer.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/6.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientLayer : NSObject

+ (CAGradientLayer*)getMyGradientLayerBySize:(CGSize)size targetStr:(NSString*)colorStr;

@end
