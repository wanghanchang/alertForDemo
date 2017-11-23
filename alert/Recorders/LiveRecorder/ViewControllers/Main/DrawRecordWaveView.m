//
//  DrawRecordWaveView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "DrawRecordWaveView.h"
#import "CommonUtils.h"



@implementation DrawRecordWaveView

#define KSIZE 20
static double _filterData[2048];

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)improveSpectrum {
        
    memset(_filterData, 0x0, sizeof(double) * 1024);
    
    if (self.dataArray.count < _wSize) {
        for (int i = 0 ; i < _wSize; i ++) {
            if (i < self.dataArray.count) {
                _filterData[i] = [self.dataArray[i] floatValue];
            } else {
                _filterData[i] = 0;
            }
        }
    } else {
        for (int i = 0 ; i < _wSize; i ++) {
            _filterData[i] = [self.dataArray[i + (_bias - _wSize)] floatValue];
        }
    }
}
//暂时不能减少
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint location = [touch locationInView:self];
//    DLog(@"--%@", NSStringFromCGPoint(location));
//    
//    
//    
//    [self.tagInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        TagInfo *tag = (TagInfo*) obj;
//        if (tag.isNew == YES) {
//            if (CGRectContainsPoint(tag.rect, location)) {
//                DLog(@"%@--%@",tag , tag.info);
//                if ([self.tagInfoArray containsObject:tag]) {
//                    [self.tagInfoArray removeObject:tag];
//                }
//            }
//        }
//    }];
//}

- (void)drawRect:(CGRect)rect {
    [self improveSpectrum];

    CGContextRef context = UIGraphicsGetCurrentContext();

    
    CGRect majorRect = rect;
    int OffsetY = self.originOffsetY * 1.5;
//时间轴相关UI部分
    for ( int i = -30; i < _wSize + 31; i++) {
        int value = _bias - _wSize;
        if (value < 0) {
            value = 0;
        }
        if (i % 30 == 0) {
            CGRect rect = CGRectMake(20, i / 30 * 45 - (value % 30 * 1.5) + 2, 40, 30);
            NSString *text= [CommonUtils translateTimeCount:(i + value) / 30];
            [[UIColor blackColor] set];
            [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:8.0]}];
            
            [[UIColor grayColor] set];
            CGContextFillRect(context, CGRectMake(0, i / 30 * 45 - (value % 30 * 1.5) + OffsetY, 10, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 10, i / 30 * 45 - (value % 30 * 1.5) + OffsetY, 10, 1));

            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0) - (value % 30 * 1.5) + OffsetY, 5, 1));

            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0 * 2.0)- (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0 * 2.0)- (value % 30 * 1.5) + OffsetY, 5, 1));

            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0 * 3.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0 * 3.0) - (value % 30 * 1.5) + OffsetY, 5, 1));

        }
    }

//halfPath
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGFloat midX = rect.size.width / 3 + rect.origin.x + 15;
    CGAffineTransform xf = CGAffineTransformIdentity;
    CGPathMoveToPoint(halfPath, nil,midX,0);
    
    for ( int i = 0; i < _wSize; i++) {
        CGPathAddLineToPoint(halfPath, nil, midX - _filterData[i], i * 1.5);
    }
    CGPathAddLineToPoint(halfPath, nil, midX , _wSize * 1.5);
// 标签相关UI
    for (TagInfo *tag in self.tagInfoArray) {
        if (tag.isNew == YES) {
            int value = _bias - _wSize;
            if (value < 0) {
                value = 0;
            }
            //alpha
            float alp;
            if (tag.sec - value < 30.0) {
                alp = (tag.sec - value) / 30.0;
            } else if (_bias - tag.sec < 30) {
                alp = (_bias - tag.sec) / 30.0;
            } else {
                alp = 1.0;
            }
            CGRect size = [tag.info boundingRectWithSize:CGSizeMake(70 , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14.0]} context:nil];
            CGRect rect = CGRectMake(self.bounds.size.width - 120, (tag.sec - value) * 1.5, 70,size.size.height);
            
            CGFloat yOffset = (tag.sec - value) * 1.5;
            CGContextAddRect(context, CGRectMake(midX, yOffset, self.bounds.size.width - 120 - midX, 1));

            CGFloat radius = 5 ;
            CGContextMoveToPoint(context, self.bounds.size.width - 120, yOffset);
            CGContextAddLineToPoint(context, self.bounds.size.width - 50 , yOffset);
            CGContextAddArc(context,self.bounds.size.width - 50 ,radius + yOffset, radius, -0.5 *M_PI, 0, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - 50 + radius, size.size.height + yOffset);
            CGContextAddArc(context, self.bounds.size.width - 50, size.size.height + yOffset, radius, 0, 0.5*M_PI, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - 150, size.size.height + yOffset + radius);
            CGContextAddArc(context, self.bounds.size.width - 120,  size.size.height + yOffset, radius, 0.5 *M_PI, M_PI, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - 120 - radius, yOffset);
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:253.0 / 255.0 green:106.0 / 255.0 blue:102.0 / 255.0 alpha:alp].CGColor);
            
            CGContextFillPath(context);
            
            tag.rectDelete = rect;
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            [tag.info drawInRect:CGRectMake(self.bounds.size.width - 120, (tag.sec - value) * 1.5 + 2, 70,size.size.height - 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14.0],
                                                       NSParagraphStyleAttributeName : paragraph,
                                                       NSForegroundColorAttributeName:[UIColor whiteColor]}];
//Img的Rect;
//            UIImage *img = [UIImage imageNamed:@"record_tab_icon_selected"];
//            CGRect rect1 = CGRectMake(self.bounds.size.width - 50, (tag.sec - value) * 1.5, 40,40);
//            [img drawInRect:rect1];
            
            if (_bias - tag.sec > _wSize + 30) {
                tag.isNew = NO;
            }
        }
    }

//fullPath
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, &xf, halfPath);
    xf = CGAffineTransformTranslate(xf, rect.size.width - rect.size.width / 3 + 30, 0);
    xf = CGAffineTransformScale(xf, -1.0, 1.0);
    CGPathAddPath(fullPath, &xf, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetStrokeColorWithColor(context, RedColor.CGColor);
    CGContextStrokePath(context);
    
//画下上下线
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
    
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextAddPath(context1, fullPath);
    CGContextSetFillColorWithColor(context1, RedColor.CGColor);
    CGContextDrawPath(context1, kCGPathFill);
    CGPathRelease(fullPath);
}


@end
