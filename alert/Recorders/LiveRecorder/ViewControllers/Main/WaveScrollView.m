//
//  WaveScrollView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "WaveScrollView.h"

@interface WaveScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign)  int timeBias;


@end

@implementation WaveScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}



-(void)tapScrollView:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_d.scroll];
    [_d dealTouchEventByLocation:CGPointMake(point.x,point.y - _d.scroll.contentOffset.y)];
}

- (instancetype)initWithFrame:(CGRect)frame withPath:(NSString*)path andInfoFilePath:(NSString *)infoFilePath timeLong:(int)timeLong {
    self = [super initWithFrame:frame];
    if (self) {
        _d = [[DrawWaveView alloc] initWithFrame:frame];
        _d.backgroundColor = WhiteColor;
        [self addSubview:_d];
        
        _d.wSize = MUSICPOINT ;
        _d.bias = 0;
        _d.timeLineOffset = 0;
        
//初始偏移4个单位 也就6px
        _d.originOffsetY = 4;
        
        _d.scroll = [[UIScrollView alloc] initWithFrame:frame];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScrollView:)];
        //设置手势属性
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired=1;//设置点按次数，默认为1，注意在iOS中很少用双击操作
        tapGesture.numberOfTouchesRequired=1;//点按的手指数
        [_d.scroll addGestureRecognizer:tapGesture];
        
        _d.scroll.backgroundColor = [UIColor clearColor];
        [_d.scroll setShowsVerticalScrollIndicator:YES];
        _d.scroll.directionalLockEnabled = YES;
        [_d.scroll alwaysBounceVertical];
        _d.scroll.delegate = self;
        [self addSubview:_d.scroll];
        

        
        
        _d.drawRealBuffer = (float *)malloc(sizeof(float) * 300) ;
        memset(_d.drawRealBuffer, 0x0, sizeof(float) * 300);
        _d.drawRealBufferCount = 300;

        if (timeLong < 600) {
            [self initPlayWaveDataWithPath:path];
            [_d.scroll setContentSize:CGSizeMake(0, ((int)ceilf(self.totalTime) + 10) * 45)];
        } else {
            [PNCProgressHUD showHUD];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self initPlayWaveDataWithPath:path];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PNCProgressHUD hideHUD];
                    [_d.scroll setContentSize:CGSizeMake(0, ((int)ceilf(self.totalTime) + 10) * 45)];
                    [_d setNeedsDisplay];
                });
            });
        }

    
#pragma mark -- 开始移动
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTime)];
        self.link.paused = YES;
        self.link.frameInterval = 2.0;
        [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
#pragma mark -- 初始化位移
        _d.bias = MUSICHALFPOINT + _d.originOffsetY;
        [_d.scroll setContentOffset:CGPointMake(0, MUSICHALFHEIGHT)];
    }
    return  self;
}

- (void)initPlayData {
    _d.bias = 0;
    float basicY = MUSICHALFHEIGHT;
    _d.timeLineOffset = basicY;

//        _sec = 0;
//        //初始偏移4个单位 也就6px
//        self.draw.originOffsetY = 4;
//        self.draw.bias = self.draw.originOffsetY;
//        
//        self.draw.dataArray = [[NSMutableArray alloc] initWithCapacity:30];
//        for (int i = 0; i < self.draw.originOffsetY; i++) {
//            [self.draw.dataArray addObject:[NSNumber numberWithInteger:0]];
//        }
//        self.draw.tagInfoArray = [[NSMutableArray alloc] initWithCapacity:5];
//        self.draw.tagInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
}

- (void)updateTime {
    float basicY = MUSICHALFHEIGHT;
    if (_d.timeLineOffset < basicY) {
        _d.timeLineOffset += 1.5;
        [_d setNeedsDisplay];

    } else {
        _d.timeLineOffset = basicY;
        _d.bias += 1.0;
        [_d.scroll setContentOffset:CGPointMake(0, _d.bias * 1.5)];
    }
}

// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动，只执行一次）
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.link.paused = YES;
    [self.delegate waveDidPaused:self.link.isPaused];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float conY =  scrollView.contentOffset.y;
    _d.bias = (int) (conY / 1.5);
    DLog(@"偏移量%d",_d.bias);
    [_d setNeedsDisplay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == YES) {
    } else {
        [self changePlayTime];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self changePlayTime];
}

- (void)changePlayTime {    
    float basicY = MUSICHALFHEIGHT;
    if (_d.scroll.contentOffset.y  < (basicY - _d.timeLineOffset)) {
        [_d.scroll setContentOffset:CGPointMake(0,  basicY - _d.timeLineOffset) animated:YES];
    } else if (_d.scroll.contentOffset.y - MUSICHALFHEIGHT > self.totalTime * 45) {
        [_d.scroll setContentOffset:CGPointMake(0, self.totalTime * 45 + basicY - _d.timeLineOffset) animated:NO
         ];
    }
    DLog(@"%.2f",self.totalTime * 45 + basicY - _d.timeLineOffset);
    [self.delegate waveChangeTimeToPlay:[self getCurrentTimePercent]];
}

- (float)getCurrentTimePercent {
    float contentY;
    float basicY = MUSICHALFHEIGHT;

    if (_d.scroll.contentOffset.y  < (basicY - _d.timeLineOffset)) {
        contentY = basicY - _d.timeLineOffset;
    } else {
        contentY = _d.scroll.contentOffset.y;
    }
#pragma mark -- calculate current time
    
    float fenMu = (self.totalTime * 45.0);
    float fenZi = (contentY - basicY + _d.timeLineOffset);
    if (fenMu - fenZi  < 1.0) {
        return 1.0;
    }
    
    float percent = fenZi / fenMu;
    if (percent < 1.0) {
        return percent;
    } else {
        return 1.0;
    }
    
}

- (void)initPlayWaveDataWithPath:(NSString*)path{
    //计算一半的位移cell数量
    struct WavInfo wavInfo;
    DLog(@"filepath = %@",path);

    decodeWaveInfo([path UTF8String], &wavInfo);
    
    self.totalTime = wavInfo.size  / (wavInfo.sample_rate * wavInfo.bits_per_sample * wavInfo.channels / 8.0);
    DLog(@"数据%d,%d,%d",wavInfo.channels,wavInfo.sample_rate,wavInfo.bits_per_sample);
    DLog(@"%.2f",self.totalTime);
    
    // 每秒30个点, 求每秒数据样本中的最大值; 然后缩放到一半的宽度内;
    
    int perSampleCounts = wavInfo.sample_rate * wavInfo.bits_per_sample * wavInfo.channels / 8 / (30);
    
    _d.drawBuffer = (float *)malloc(sizeof(float) * wavInfo.size / perSampleCounts) ;
    _d.drawBufferCount = wavInfo.size / perSampleCounts;
    
    DLog(@"BufCount = %d",_d.drawBufferCount);
    
    short *realWaveInfo = (short *)malloc(sizeof(short) * wavInfo.size / 2);
    //16bit 2byte--short; 真实的16bit值;
    for (int i = 0; i < wavInfo.size / 2; i++) {
        realWaveInfo[i] = [self charToShort:wavInfo.data[i * 2] andChar:wavInfo.data[(i * 2) + 1]];
    }
    
    free(wavInfo.data);
    
    for (int i = 0; i < wavInfo.size / perSampleCounts; i++) {
        //因为数据少了一半
        _d.drawBuffer[i] = [self RMS:&realWaveInfo[i * (perSampleCounts/ 2)] length:perSampleCounts / 2];
        if (i < 3) {
            _d.drawBuffer[i] = 0;
        }
    }
    free(realWaveInfo);
    realWaveInfo = NULL;
    
    //找到最大值
    float max = 0;
    for (int i = 0;i < wavInfo.size / perSampleCounts; i++) {
        max = max > _d.drawBuffer[i] ? max : _d.drawBuffer[i];
    }
    //scale
    for (int i = 0; i < wavInfo.size / perSampleCounts; i++) {
        _d.drawBuffer[i] = 70 * ADJUSTWIDTH / max * _d.drawBuffer[i] ;
    }
    //加上半个空距离的数据量
    int value = MUSICHALFPOINT + _d.originOffsetY;
    DLog(@"%d",_d.originOffsetY);
    

    
    _d.drawRealBuffer = (float *)realloc(_d.drawRealBuffer,sizeof(float) * ((wavInfo.size / perSampleCounts) + value)) ;
    memset(_d.drawRealBuffer, 0x0, sizeof(float) * ((wavInfo.size / perSampleCounts) + value));
    _d.drawRealBufferCount = _d.drawBufferCount + value;
    
    for (int i = 0; i < _d.drawRealBufferCount; i++) {
        if (i < value) {
            _d.drawRealBuffer[i] = 0;
        } else {
            _d.drawRealBuffer[i] = _d.drawBuffer[i - value];
        }
    }
    free(_d.drawBuffer);
    _d.drawBuffer = NULL;
}

- (short)charToShort:(char)a andChar:(char)b {
    short c;
    c = (((short)b)<<8)|((short)a);//0xABFE
    return c;
}

- (float)RMS:(short *)perSample length:(int)length {
    short max = 0;
    for (int i = 0 ; i < length; i++) {
        short value = (short)abs(perSample[i]);
        max = max > value ? max : value;
    }
    return (float)max;
}

@end
