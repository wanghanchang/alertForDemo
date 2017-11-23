//
//  UIColor+Hex.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    if ([[hexString substringToIndex:1] isEqualToString:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

+ (UIImage*)imageFromHexString:(NSString*)hexString {
    UIColor* color = [UIColor colorFromHexString:hexString];
    return [UIColor createImageFromColor:color];
}

+ (UIImage*) createImageFromColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)imageFromHexString:(NSString*)hexString alpha:(float)alpha {
    if ([[hexString substringToIndex:1] isEqualToString:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    UIColor *color = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                                     green:((rgbValue & 0xFF00) >> 8)/255.0
                                      blue:(rgbValue & 0xFF)/255.0
                                     alpha:alpha];
    return [UIColor createImageFromColor:color];
}

@end
