//
//  DrawRecordWaveView.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagInfo.h"
#import "MyImage.h"

@interface DrawRecordWaveView : UIView


@property float *drawBuffer;
@property int drawBufferCount;

@property int wSize;
@property int bias;

@property float *drawRealBuffer;
@property int drawRealBufferCount;

@property int originOffsetY;

@property (nonatomic,strong) NSMutableArray *dataArray;


@property (nonatomic,strong) NSMutableArray *tagInfoArray;

@property (nonatomic,strong) NSMutableDictionary *tagInfoDic;

- (instancetype)initWithFrame:(CGRect)frame;



@end
