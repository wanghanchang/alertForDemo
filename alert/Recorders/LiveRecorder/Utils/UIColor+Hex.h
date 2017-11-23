//
//  UIColor+Hex.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIImage*)imageFromHexString:(NSString*)hexString;

+ (UIImage*) createImageFromColor: (UIColor*) color;

+ (UIImage*)imageFromHexString:(NSString*)hexString alpha:(float)alpha;

@end
