//
//  MainViewController.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseViewController.h"
#import "DrawRecordWaveView.h"

typedef NS_ENUM(NSUInteger, AudioQueueState) {
    AudioQueueState_Idle,
    AudioQueueState_Recording,
    AudioQueueState_Playing,
};

@interface MyData : NSObject

@property (nonatomic,strong) NSMutableData * data;
@property (nonatomic) BOOL isNewData;
@property (nonatomic) int times;
@end


@interface MainViewController : BaseViewController
@property (nonatomic,assign) AudioQueueState currentState;

@property (nonatomic,strong) CADisplayLink *link;
@property (nonatomic,strong) DrawRecordWaveView *draw;
@property (nonatomic,assign) int sec;
@property (nonatomic,strong) MyData *myData;
@property (nonatomic) SInt16 *numData;

+ (instancetype)controller;
- (void)addCurrentRecord;
@end
