//
//  PlayViewController.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/13.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseViewController.h"
#import "LiveRecordHelper.h"
#import <AVFoundation/AVFoundation.h>


@interface PlayViewController : BaseViewController

- (instancetype)initWithFileName:(EntityLiveRecord *)entity;

- (void)reloadTranslate;

@property (nonatomic,strong) EntityLiveRecord *entity;

@property (nonatomic,assign) BOOL seeTranslate;

+ (AVAudioPlayer *)player;

@end
