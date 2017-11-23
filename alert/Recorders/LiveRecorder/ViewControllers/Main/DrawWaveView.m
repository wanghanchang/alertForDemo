//
//  DrawView2.m
//  MYWAVE
//
//  Created by 匹诺曹 on 17/4/7.
//  Copyright © 2017年 匹诺曹. All rights reserved.


#import "DrawWaveView.h"
#import <Masonry.h>
#import "PNCInputDialog.h"

@implementation DrawWaveView

#define KSIZE 20
static float _filterData[1024];

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)improveSpectrum {
    memset(_filterData, 0x0, sizeof(float) * 1024);
    float transData[self.wSize];
    memcpy(transData, self.drawRealBuffer + _bias, _wSize * sizeof(float));
        for (int i = 0 ; i < _wSize; i ++) {
            if (_bias + i > self.drawRealBufferCount - 1) {
                _filterData[i] = 0 ;
            } else if (_bias + i < 0) {
                _filterData[i] = 0;
            } else {
                _filterData[i] = transData[i];
            }
        }
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint location = [touch locationInView:self];
//    [self.tagInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        TagInfo *tag = (TagInfo*) obj;
//        if (tag.isNew == YES) {
//            if (CGRectContainsPoint(tag.rectDelete, location)) {
//                if ([self.tagInfoArray containsObject:tag]) {
//                    [self.tagInfoArray removeObject:tag];                
//                    [self setNeedsDisplay];
//                }
//            }
//        }
//    }];
//}

- (void)dealTouchEventByLocation:(CGPoint)location {
    
    [self.tagInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TagInfo *tag = (TagInfo*) obj;
        if (tag.isNew == YES) {
            DLog(@"%@",NSStringFromCGRect(tag.rectDelete));
            
            if (CGRectContainsPoint(tag.rectDelete, location)) {
                if ([self.tagInfoArray containsObject:tag]) {
                    [self.tagInfoArray removeObject:tag];
                    [self setNeedsDisplay];
                }
            }
            
            if (CGRectContainsPoint(tag.rectNote, location)) {
                if ([self.tagInfoArray containsObject:tag]) {
//                    tag.info = @"测试我们我女的你是蓝的懒散的懒散看楼三楼的你卡死";
                    [[PNCInputDialog inputWithTitle:@"提示" andHint:@"输入文字" andOriginText:@"" containsButtonTitles:@[@"确定",@"取消"] andCommitBlock:^(PNCDialog *dialog, NSString *content, int buttonIndex) {
                        if (buttonIndex == 0) {
                            tag.info = content;
                        }
                        [dialog hide];
                        [self setNeedsDisplay];
                    }] show];

                }
            }
        }
    }];
}

- (void)drawRect:(CGRect)rect {
    [self improveSpectrum];

    CGContextRef context = UIGraphicsGetCurrentContext();
                
    CGRect majorRect = rect;
    int OffsetY = self.originOffsetY * 1.5;
    
    //时间轴相关UI部分
    for ( int i = -30; i < _wSize + 31; i++) {
        int value = _bias + MUSICHALFPOINT - _wSize + 300;

        if (i % 30 == 0) {
            CGRect rect = CGRectMake(20, i / 30 * 45 - (value % 30 * 1.5) + 2, 40, 30);
            int time = ((i + value) / 30) - 10;
            NSString *text;
            if (time < 0) {
            } else {
                text = [CommonUtils translateTimeCount:((i + value) / 30) - 10];
            }
            [[UIColor redColor] set];
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
    
    CGFloat midX = rect.size.width / 3 + rect.origin.x + 15;
    
    //halfPath
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGAffineTransform xf = CGAffineTransformIdentity;
    CGPathMoveToPoint(halfPath, nil,midX,0);
    
    for ( int i = 0; i < _wSize; i++) {
        CGPathAddLineToPoint(halfPath, nil, midX - _filterData[i], i * 1.5);
    }
    CGPathAddLineToPoint(halfPath, nil, midX , _wSize * 1.5);
    // 标签相关UI
    for (TagInfo *tag in self.tagInfoArray) {            
        float value = tag.sec * 1.5 + (_wSize / 2 * 1.5) - _bias * 1.5;
        if (fabsf(value) > _wSize * 1.5 ) {
            tag.isNew = NO;
        } else {
            tag.isNew = YES;
        }
        if (tag.isNew) {
            float alp = 1.0;

            int leftOffset = 140 * ADJUSTWIDTH;
            int rightOffset = 60 * ADJUSTWIDTH;
            CGRect size = [tag.info boundingRectWithSize:CGSizeMake(leftOffset - rightOffset, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14.0]} context:nil];
            CGRect rect = CGRectMake(self.bounds.size.width - leftOffset, value, leftOffset - rightOffset,size.size.height);
            
            CGFloat yOffset = value;
            CGContextAddRect(context, CGRectMake(midX, yOffset, self.bounds.size.width - leftOffset - midX, 1));
            
            CGFloat radius = 5 ;
            CGContextMoveToPoint(context, self.bounds.size.width - leftOffset, yOffset);
            CGContextAddLineToPoint(context, self.bounds.size.width - rightOffset , yOffset);
            CGContextAddArc(context,self.bounds.size.width - rightOffset ,radius + yOffset, radius, -0.5 *M_PI, 0, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - rightOffset + radius, size.size.height + yOffset);
            CGContextAddArc(context, self.bounds.size.width - rightOffset, size.size.height + yOffset, radius, 0, 0.5*M_PI, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - leftOffset, size.size.height + yOffset + radius);
            CGContextAddArc(context, self.bounds.size.width - leftOffset,  size.size.height + yOffset, radius, 0.5 *M_PI, M_PI, 0);
            
            CGContextAddLineToPoint(context, self.bounds.size.width - leftOffset - radius, yOffset);
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:253.0 / 255.0 green:106.0 / 255.0 blue:102.0 / 255.0 alpha:alp].CGColor);
            CGContextFillPath(context);
            
            
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            [tag.info drawInRect:CGRectMake(self.bounds.size.width - leftOffset, value  + 1, leftOffset - rightOffset,size.size.height + 1) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14.0],
                                                       NSParagraphStyleAttributeName : paragraph,
                                                       NSForegroundColorAttributeName:[UIColor whiteColor]}];
            
            tag.rectNote = rect;
            
            //Img的Rect;
            UIImage *img = [UIImage imageNamed:@"wave_play_delete"];
            CGRect rect1 = CGRectMake(self.bounds.size.width - 45 * ADJUSTWIDTH,  value - 4, 26,26);
            [img drawInRect:rect1];
            tag.rectDelete = rect1;

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

    
    //leftLine
    CGContextAddArc(context, rect.origin.x + 14, OffsetY + self.timeLineOffset, 4, 0,2* M_PI, 0);
    CGContextMoveToPoint(context, rect.origin.x + 18, OffsetY + self.timeLineOffset);
    CGContextAddLineToPoint(context, midX, OffsetY + self.timeLineOffset);
    [RedColor set];
    CGContextStrokePath(context);
}

@end

