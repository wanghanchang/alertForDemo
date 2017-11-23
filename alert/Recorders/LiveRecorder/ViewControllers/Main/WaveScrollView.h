//
//  WaveScrollView.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawWaveView.h"
#import "WavaData.h"


@protocol WaveViewDidChangeDelegate <NSObject>

- (void)waveChangeTimeToPlay:(float)currentTime;

- (void)waveDidPaused:(BOOL)paused;

@end

@interface WaveScrollView : UIView

@property (nonatomic,assign) int sec;

@property (nonatomic,strong) NSMutableDictionary *infoDic;

@property (nonatomic,strong) DrawWaveView *d;

@property (nonatomic,assign) float totalTime;

@property (nonatomic,strong) CADisplayLink *link;

@property (nonatomic,strong) UIView *timeScrollLine;

@property (nonatomic,assign) int biasHalf;

@property (nonatomic,strong) UILabel *label;

@property (nonatomic,weak) id<WaveViewDidChangeDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withPath:(NSString*)path andInfoFilePath:(NSString *)infoFilePath timeLong:(int)timeLong;

- (void)initPlayData;

@end
