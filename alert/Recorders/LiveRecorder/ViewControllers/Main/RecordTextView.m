//
//  RecordTextView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/13.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "RecordTextView.h"

@implementation RecordTextView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画下上下线
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
}
@end
