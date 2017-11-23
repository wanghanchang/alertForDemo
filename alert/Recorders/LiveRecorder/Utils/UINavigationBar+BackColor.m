//
//  UINavigationBar+BackColor.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "UINavigationBar+BackColor.h"

@implementation UINavigationBar (BackColor)

- (void)setColor:(UIColor*)color {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -20, SCREENWIDTH, 64)];
    view.backgroundColor = color;
    [self setValue:view forKey:@"backgroundView"];
}

@end
