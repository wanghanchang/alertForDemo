//
//  DrawView2.h
//  MYWAVE
//
//  Created by 匹诺曹 on 17/4/7.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagInfo.h"

#define MUSICHEIGHT (get_music_height())
#define MUSICHALFHEIGHT MUSICHEIGHT /  2
#define MUSICPOINT      MUSICHEIGHT / 1.5
#define MUSICHALFPOINT MUSICPOINT / 2
#define SINGLEHEIGHT    45

@interface DrawWaveView : UIView
//一个单位屏幕总的点个数
@property int wSize;
//Array数据总偏移
@property int bias;

@property float *drawBuffer;
@property int drawBufferCount;

@property float *drawRealBuffer;
@property int drawRealBufferCount;
//一个初始的 小偏移量
@property int originOffsetY;
//时间轴哦偏移量
@property float timeLineOffset;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)dealTouchEventByLocation:(CGPoint)location;

@property (nonatomic,strong) NSMutableArray *tagInfoArray;

@property (nonatomic,strong) UIScrollView *scroll;

@end

