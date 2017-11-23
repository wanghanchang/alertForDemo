//
//  MainViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "MainViewController.h"
#import "PNCAlertDialog.h"
#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WavaData.h"
#import "LiveRecordHelper.h"
#import "PNCInputDialog.h"
#import "PNCTagDialog.h"
#import "RecordFileViewController.h"
#import "NSString+Trim.h"
#import "LoginRequest.h"

#import "RecordFileEditInfoAlert.h"
#import "UMessage.h"
#import <lame/lame.h>
#import "TestViewController.h"

#import "PNCProgressDialog.h"

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

#import "OrderStateViewController.h"
#import "AppDelegate.h"

@implementation MyData

- (instancetype)init {
    if (self  = [super init]) {
        self.data = [[NSMutableData alloc] init];
        self.isNewData = NO;
        self.times = 1;
    }
    return self;
}

@end


@interface MainViewController ()<AVAudioRecorderDelegate>
{
    lame_t lame;
    BOOL _setToStopped;
}
@property (strong, nonatomic) NSURL *audioFileURL;


@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *recordRemainTimeLabel;

@property (nonatomic,strong) UIButton *recordBtn;
@property (nonatomic,strong) UILabel *recordBtnLabel;

@property (nonatomic,strong) UIButton *stopRecordBtn;
@property (nonatomic,strong) UILabel *stopRecordBtnLabel;

@property (nonatomic,strong) UIButton *tagButton;
@property (nonatomic,strong) UILabel *tagButtonLabel;


@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic) int startTimeStamp;

@property (nonatomic,assign) BOOL bCanRecord;

@property (nonatomic,strong) CTCallCenter *callCenter;  //必须在这里声明，要不不会回调block
@end

#define NUM_BUFFERS 5

static SInt64 currentByte;
static AudioStreamBasicDescription audioFormat;
static AudioQueueRef queue;
static AudioQueueBufferRef buffers[NUM_BUFFERS];
static AudioFileID audioFileID;

static MainViewController *main = nil;

@implementation MainViewController

void AudioInputCallback(
                        void *inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp *inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription *inPacketDescs
                        ) {
    MainViewController *viewController = (__bridge MainViewController*)inUserData;
    
    if (viewController.currentState != AudioQueueState_Recording) {
        return;
    }
    
    UInt32 ioBytes = audioFormat.mBytesPerPacket * inNumberPacketDescriptions;
    
    
    SInt16 * data = (SInt16 *)inBuffer->mAudioData;
    
    long size = inBuffer->mAudioDataByteSize / audioFormat.mBytesPerPacket;
    
    NSData *codeData = [[NSData alloc] initWithBytes:data length:size];
    
    
    [viewController.myData.data appendData:codeData];
    viewController.myData.isNewData = YES;
    viewController.myData.times = 1;
    
    viewController.numData = data;
    
    OSStatus status = AudioFileWriteBytes(audioFileID,
                                          false,
                                          currentByte,
                                          &ioBytes,
                                          inBuffer->mAudioData);
    if (status != noErr) {
        printf("Error");
        return;
    }
    currentByte += ioBytes;
    status = AudioQueueEnqueueBuffer(queue, inBuffer, 0, NULL);
}

- (void)conventToMp3 {
    
    lame = lame_init();
    lame_set_in_samplerate(lame, 11025.0);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);
    
    NSString *mp3FilePath = [CommonUtils generateFilePathWithFileName:self.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:NO];
    mp3FilePath = [mp3FilePath stringByAppendingString:@".mp3"];
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([_path cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        long curpos;
        BOOL isSkipPCMHeader = NO;
        
        do {
            
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //Uump audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
            }
            
            else {
                [NSThread sleepForTimeInterval:0.05];
            }
        } while (!_setToStopped);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        DLog(@"成功MP3");
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)goPlay {
    TestViewController *v = [[TestViewController alloc] init];
//    OrderStateViewController *v = [[OrderStateViewController alloc] init];

    [self.navigationController pushViewController:v animated:YES];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isRecording:) name:@"isRecording" object:nil];
}

- (void)isRecording:(NSNotification*)noti {
    [self runAfterSecs:.5 block:^{
        NSNumber *time=   [noti object];
        if ([time floatValue] > 0) {
            _timeLabel.text = [CommonUtils translateTimeCount:[time floatValue]];
        }
        [self.draw setNeedsDisplay];
        [_recordBtn setImage:[UIImage imageNamed:@"begin_main"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"pause_main"] forState:UIControlStateSelected];
        self.recordBtn.selected = NO;
        self.recordBtnLabel.text = @"继续";
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForNotifications];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float level = [UIDevice currentDevice].batteryLevel * 100;
    NSString *str = [NSString stringWithFormat:@"手机还可以录%.1f小时以上",level / 10.0];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor redColor]
                          range:NSMakeRange(6, AttributedStr.length - 6)];
    _recordRemainTimeLabel.attributedText = AttributedStr;
}


+ (instancetype)controller {
    if (!main) {
        main = [[MainViewController alloc] init];
    }
    return main;
}

- (void)dealCallData {
    if (self.currentState == AudioQueueState_Recording) {
        AudioQueuePause(queue);
        self.link.paused = YES;
        float time = _sec / 30.0;
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (delegate.isBackGround == YES && self.currentState == AudioQueueState_Recording) {
            [delegate stopTimer];
        }
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:time] forKey:@"isRecording"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self justifyUpdate];
    __weak MainViewController *ws = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler=^(CTCall* call){
        if([call.callState isEqualToString:CTCallStateDisconnected]) {
            DLog(@"Call has been disconnected");
        } else if([call.callState isEqualToString:CTCallStateConnected]) {
            DLog(@"Callhasjustbeen connected");
        } else if([call.callState isEqualToString:CTCallStateIncoming]) {
            DLog(@"Call is incoming");
            [ws runInGlobalQueue:^{
                [ws dealCallData];
            }];
        } else if([call.callState isEqualToString:CTCallStateDialing]) {
            [ws runInGlobalQueue:^{
                [ws dealCallData];
            }];

            DLog(@"Call is Dialing");
        } else {
            DLog(@"Nothing is done");
        }
    };
    

    
    [UMessage addAlias:[[AccountInfo shareInfo] uid] type:@"alias_uid" response:nil];
//            UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc] initWithTitle:@"播放" style:UIBarButtonItemStylePlain target:self action:@selector(goPlay)];
//            self.navigationItem.rightBarButtonItem = barBtn1;

    
    self.myData = [[MyData alloc] init];
    [self setupAudio];
    
    self.title = @"现场录音";
    self.view.backgroundColor = WhiteColor;
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTime)];
    self.link.paused = YES;
    self.link.frameInterval = 2.0;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.draw = [[DrawRecordWaveView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 270 * ADJUSTHEIGHT)];
    self.view.userInteractionEnabled = YES;
    self.draw.userInteractionEnabled = YES;
    self.draw.wSize = 270 * ADJUSTHEIGHT / 1.5;
    self.draw.backgroundColor = WhiteColor;
    [self initRecordData];
    [self.view addSubview:self.draw];
    [self initUI];

    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isNewRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.stopRecordBtn setEnabled:false];
    [self.tagButton setEnabled:false];
}

#pragma mark - Audio Setup
- (void)setupAudio {
    audioFormat.mSampleRate = 22050.0;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(SInt16);
    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    self.currentState = AudioQueueState_Idle;
}

- (void)justifyUpdate {
    [LoginRequest justifyVersionWithCode:[CommonUtils getVersionInt] WithReturnKey:^(int a, NSDictionary *dic) {
        if ( a == HTTP_OK) {
            NSArray *array;
            int updateType = [dic[@"updateType"] intValue];
            
            if (updateType == 0) {
            } else if (updateType == 1) {
                array = @[@"确定",@"取消"];
                [[PNCAlertDialog alertWithTitle:@"提示"
                                     andMessage:dic[@"updateLog"]
                           containsButtonTitles:array
                           buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                               if (buttonIndex == 0) {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dic[@"downUrl"]]];
                               }
                               [dialog hide];
                           }] show];
                
            } else {
                array = @[@"确定"];
                [[PNCAlertDialog forceAlertWithTitle:@"提示"
                                          andMessage:dic[@"updateLog"]
                                containsButtonTitles:array
                                buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                                    if (buttonIndex == 0) {
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dic[@"downUrl"]]];
                                    }
                                    [dialog hide];
                                }] show];
            }
        }
    }];
}


- (void)updateTime {
    _sec += 1;
    self.draw.bias += 1.0;
    float creationFloat = 50.0 * ADJUSTWIDTH;
    if (self.numData) {
        if (_sec < 4) {
            [self.draw.dataArray addObject:[NSNumber numberWithFloat:0.0]];
        } else {
            if (self.myData.isNewData == YES) {
                int max = 0;
                for ( int i= 0 ; i < 1024 / 3 * self.myData.times ; i ++ ) {
                    max =  max > self.numData[i] ? max : self.numData[i];
                }
                self.myData.isNewData = NO;
                float value;
                
                if (max > 16383.50) {
                    value =  (max - 16383.50) / 16383.50 * creationFloat / 2 + creationFloat;
                } else {
                    value = max / 16383.50 * creationFloat;
                }
                [self.draw.dataArray addObject:[NSNumber numberWithFloat:value]];
                self.myData.times ++;
            } else {
                int max = 0;
                for ( int i= 0 ; i < 1024 / 3 * self.myData.times ; i ++ ) {
                    max =  max > self.numData[i] ? max : self.numData[i];
                }
                float value;
                if (max > 16383.50) {
                    value =  (max - 16383.50) / 16383.50 * creationFloat /2 + creationFloat;
                } else {
                    value = max / 16383.50 * creationFloat;
                }
                [self.draw.dataArray addObject:[NSNumber numberWithFloat:value]];
                self.myData.times ++;
                if (self.myData.times > 3) {
                    self.myData.times = 3;
                }
            }
        }
    } else {
        [self.draw.dataArray addObject:[NSNumber numberWithFloat:0.0]];
    }
 

    [self.draw setNeedsDisplay];
    _timeLabel.text = [CommonUtils translateTimeCount:_sec / 30];
}

- (void)tagIt {
//    点我
    TagInfo *info = [[TagInfo alloc] init];
    info.sec = _sec;
    info.info = @"标记";
    info.isNew = YES;
    
    __block BOOL canAdd = YES;
    [self.draw.tagInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TagInfo *i = (TagInfo*)obj;
        if (abs(i.sec - info.sec) < 60) {
            canAdd = NO;
            *stop = YES;
        }
    }];
    
    if (canAdd == YES) {
        [self.draw.tagInfoArray addObject:info];
        [self.draw.tagInfoDic setObject:info.info forKey:[NSString stringWithFormat:@"%d",info.sec]];
    } else {
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.backgroundColor = c_000000;
        hintLabel.alpha = 0.0;
        hintLabel.text = @"2s内无文字";
        hintLabel.textColor = WhiteColor;
        hintLabel.layer.cornerRadius = 2;
        hintLabel.layer.masksToBounds = YES;
        [self.view addSubview:hintLabel];
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.bottom.mas_equalTo(self.draw.mas_bottom).with.offset(-10);
            make.height.mas_equalTo(hintLabel.mas_height);
            make.width.mas_equalTo(hintLabel.mas_width);
        }];
        [UIView animateWithDuration:1.0 animations:^{
            hintLabel.alpha = 0.75;
        } completion:^(BOOL finished){
            [hintLabel removeFromSuperview];
        }];
    }
  
}

- (void)setTabBaritemSelected:(BOOL)selected {
    self.navigationController.tabBarController.childViewControllers[1].tabBarItem.enabled = selected;
    self.navigationController.tabBarController.childViewControllers[2].tabBarItem.enabled = selected;
    self.navigationController.tabBarController.childViewControllers[3].tabBarItem.enabled = selected;
}

- (void)finishRecord {
    [self setTabBaritemSelected:YES];

    _setToStopped = YES;
    _recordBtn.selected = NO;
    self.recordBtnLabel.text = @"开始";
    self.link.paused = YES;
    _recordBtn.selected = false;

    
    self.currentState = AudioQueueState_Idle;
    AudioQueueStop(queue, true);
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(queue, buffers[i]);
    }
    AudioQueueDispose(queue, true);
    AudioFileClose(audioFileID);
    
    [self finish];
//    kAudioQueueProperty_IsRunning;
    //    ios中用AudioQueueRef播放音频，是比较底层的方法。已经接触了很长时间了，不过一直没有弄太明白。
    //    今天沉下心来做了些测试，总结一下：
    //    1、调用AudioQueueStop(queue, true);停止播放器，系统会自动调用三次回调函数，kAudioQueueProperty_IsRunning状态为停止状态
    //    2、调用AudioQueuePause(queue);暂停播放器，kAudioQueueProperty_IsRunning状态为非停止状态
    //    3、当三个缓冲区播放完成时候，没有更多的数据往里面添加，播放器会停止播放(一种特殊的等待状态，不再继续回调)，
    //    这时候调用AudioQueueStart(queue, NULL);是无效的，不会继续调用回调函数，而是应该再往缓冲区里面添加数据，播放器会自动继续播放。
}

- (void)finish {
    NSString *txtPath = [CommonUtils generateFilePathWithFileName:self.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:YES];
    BOOL isWrite = [CommonUtils writeJsonDataFromDictionaryByPath:txtPath withDic:self.draw.tagInfoDic];
    if (isWrite) {
        DLog(@"finish");
    }
    RecordFileEditInfoAlert *alert =  [[RecordFileEditInfoAlert alloc] initWithFrame:CGRectMake(40 * ADJUSTWIDTH ,SCREENHEIGHT / 4, (SCREENWIDTH - (80 * ADJUSTWIDTH)), 300 * ADJUSTHEIGHT) WithCancelName:@"删除" WithObj:nil  WithBlock:^(RecordFileEditInfoAlert *myAlert, int buttonindex, TagAlertObj *obj) {
            if (buttonindex == 1) {
            //增加新的录音
            LiveRecordHelper *helper = [LiveRecordHelper helper];
            EntityLiveRecord *entity = [[EntityLiveRecord alloc] init];
            NSData* dataOfAudio = [NSData dataWithContentsOfFile:_path];
            entity.fileLength = [dataOfAudio length];
            entity.fileName = self.fileName;
            entity.timeLong = _sec / 30.0 < 1 ? 1 : _sec / 30.0;
            entity.startTime = self.startTimeStamp;
            entity.isFinishBindOrder = NO;
            entity.isFinishUplaod = NO;
            if (obj.recordName.length == 0) {
                entity.userNamedFile = @"未命名";
            } else {
                entity.userNamedFile = obj.recordName;
            }
            entity.recordTagColor = obj.tagColor;
            entity.recordTag = obj.tagName;
            [helper add:entity];
            [myAlert hide];
            [self prepareForNewRecord];
            [self translate];
        } else {
            [CommonUtils delteFilehWithFileName:self.fileName andFileManagerName:[[AccountInfo shareInfo] mobile]];
            [self prepareForNewRecord];
            [myAlert hide];
        }
    }];
    [alert show];
}

- (void)addCurrentRecord {
    LiveRecordHelper *helper = [LiveRecordHelper helper];
    EntityLiveRecord *entity = [[EntityLiveRecord alloc] init];
    NSData* dataOfAudio = [NSData dataWithContentsOfFile:_path];
    entity.fileLength = [dataOfAudio length];
    entity.fileName = self.fileName;
    entity.timeLong = _sec / 30.0 < 1 ? 1 : _sec / 30.0;
    entity.startTime = self.startTimeStamp;
    entity.isFinishBindOrder = NO;
    entity.isFinishUplaod = NO;
    entity.userNamedFile = @"未命名";
    entity.recordTagColor = @"#999999";
    entity.recordTag = @"未分组";
    [helper add:entity];
    
    AudioQueueStop(queue, true);
    AudioQueueDispose(queue, true);
    AudioFileClose(audioFileID);
}

- (void)pauseRecording {
    AudioQueuePause(queue);
    self.link.paused = YES;
    self.recordBtnLabel.text = @"继续";
}

- (void)continueRecording {
    self.recordBtnLabel.text = @"暂停";
    self.link.paused = NO;
    AudioQueueStart(queue, NULL);
}

- (void)initRecordData {
    _sec = 0;
    //初始偏移4个单位 也就6px
    self.draw.originOffsetY = 4;
    self.draw.bias = self.draw.originOffsetY;
    
    self.draw.dataArray = [[NSMutableArray alloc] initWithCapacity:30];
    for (int i = 0; i < self.draw.originOffsetY; i++) {
        [self.draw.dataArray addObject:[NSNumber numberWithInteger:0]];
    }
    self.draw.tagInfoArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.draw.tagInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
}

//准备新的录音
- (void)prepareForNewRecord {

    [self initRecordData];
    self.recordBtnLabel.text = @"开始";
    _timeLabel.text = @"00:00:00";
    [self.draw setNeedsDisplay];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isNewRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.stopRecordBtn setEnabled:false];
    [self.tagButton setEnabled:false];
}

- (void)translate {
    self.tabBarController.selectedIndex = 1;
//    UINavigationController *con = self.tabBarController.viewControllers[1];
//    RecordFileViewController *record = con.viewControllers[0];
//    record.isNewUndinfedRecord = YES;
}

- (void)startRecord {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isNewRecord"] integerValue] == 1 ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isNewRecord"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self audioRecordPrepare];
        return;
    }

#pragma mark --Min
    if (_recordBtn.selected) {
        [self pauseRecording];
    } else {
        [self continueRecording];
    }
    _recordBtn.selected = !_recordBtn.selected;
}

- (void)audioRecordPrepare {

    self.fileName = [CommonUtils currentTimeStr];
    self.startTimeStamp = [[NSDate date] timeIntervalSince1970];
    _path = [CommonUtils generateFilePathWithFileName:self.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:NO];
    DLog(@"PATH = %@",_path);
    _path = [_path stringByAppendingString:@".wav"];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    NSAssert(error == nil, @"Error");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    NSAssert(error == nil, @"Error");
    

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            [self runInMainQueue:^{
                [self setTabBaritemSelected:NO];
                
                UINavigationController *navifile =  self.navigationController.tabBarController.childViewControllers[1];
                [navifile popToRootViewControllerAnimated:YES];

                
                _bCanRecord = YES;
                _recordBtnLabel.text = @"暂停";
                _setToStopped = NO;
                _link.paused = NO;
                _recordBtn.selected = YES;
                [_stopRecordBtn setEnabled:true];
                [_tagButton setEnabled:true];
                _currentState = AudioQueueState_Recording;
                currentByte = 0;
                
                OSStatus status;
                status = AudioQueueNewInput(&audioFormat,
                                            AudioInputCallback, (__bridge void*)self,
                                            CFRunLoopGetCurrent(),
                                            kCFRunLoopCommonModes,
                                            0,
                                            &queue);
                NSAssert(status == noErr, @"Error");
                
                for (int i = 0; i < NUM_BUFFERS; i++) {
                    status = AudioQueueAllocateBuffer(queue, 2048, &buffers[i]);
                    NSAssert(status == noErr, @"Error");
                    status = AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL);
                    NSAssert(status == noErr, @"Error");
                }
                
                _audioFileURL = [NSURL URLWithString:_path];
                
                status = AudioFileCreateWithURL((__bridge CFURLRef)self.audioFileURL,
                                                kAudioFileWAVEType,
                                                &audioFormat,
                                                kAudioFileFlags_EraseFile,
                                                &audioFileID);
                NSAssert(status == noErr, @"Error");
                
                NSAssert(status == noErr, @"Error");
                AudioQueueStart(queue, NULL);
                [self runInGlobalQueue:^{
                    [self conventToMp3];
                }];
            }];
        } else {
            _bCanRecord = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                           delegate:nil
                                  cancelButtonTitle:@"关闭"
                                  otherButtonTitles:nil] show];
                
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isNewRecord"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return;
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:50 * ADJUSTHEIGHT];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = c_333333;
        _timeLabel.text = @"00:00:00";
    }
    return _timeLabel;
}

- (UILabel *)recordRemainTimeLabel {
    if (!_recordRemainTimeLabel) {
        _recordRemainTimeLabel = [UILabel new];
        _recordRemainTimeLabel.font = [UIFont systemFontOfSize:12];
        _recordRemainTimeLabel.textAlignment = NSTextAlignmentCenter;
        _recordRemainTimeLabel.textColor = c_333333;
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"手机还可以录10小时以上"];
        [AttributedStr addAttribute:NSForegroundColorAttributeName
                              value:[UIColor redColor]
                              range:NSMakeRange(6, AttributedStr.length - 6)];
        _recordRemainTimeLabel.attributedText = AttributedStr;
    }
    return _recordRemainTimeLabel;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setImage:[UIImage imageNamed:@"begin_main"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"pause_main"] forState:UIControlStateSelected];
        [_recordBtn setBackgroundColor:RedColor];
        [_recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (UILabel *)recordBtnLabel {
    if (!_recordBtnLabel) {
        _recordBtnLabel = [[UILabel alloc] init];
        _recordBtnLabel.text = @"开始";
        _recordBtnLabel.textColor = RedColor;
        _recordBtnLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _recordBtnLabel;
}

- (UIButton *)stopRecordBtn {
    if (!_stopRecordBtn) {
        _stopRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopRecordBtn setImage:[UIImage imageNamed:@"end_main"] forState:UIControlStateNormal];
        [_stopRecordBtn setBackgroundColor:c_FF9A47];
        [_stopRecordBtn setBackgroundImage:[UIColor imageFromHexString:@"#CCCCCC"] forState:UIControlStateDisabled];
        [_stopRecordBtn addTarget:self action:@selector(finishRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopRecordBtn;
}

- (UILabel *)stopRecordBtnLabel {
    if (!_stopRecordBtnLabel) {
        _stopRecordBtnLabel = [[UILabel alloc] init];
        _stopRecordBtnLabel.text =@"结束";
        _stopRecordBtnLabel.font = [UIFont systemFontOfSize:14.0];
        _stopRecordBtnLabel.textColor = c_FF9A47;
    }
    return _stopRecordBtnLabel;
}

- (UIButton *)tagButton {
    if (!_tagButton) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tagButton setImage:[UIImage imageNamed:@"tag_main"] forState:UIControlStateNormal];
        [_tagButton setBackgroundColor: c_2fc7f7];
        [_tagButton setBackgroundImage:[UIColor imageFromHexString:@"#CCCCCC"] forState:UIControlStateDisabled];
        [_tagButton addTarget:self action:@selector(tagIt) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tagButton;
}

- (UILabel *)tagButtonLabel {
    if (!_tagButtonLabel) {
        _tagButtonLabel = [[UILabel alloc] init];
        _tagButtonLabel.textColor = c_2fc7f7;
        _tagButtonLabel.font = [UIFont systemFontOfSize:14.0];
        _tagButtonLabel.text = @"标记";
    }
    return _tagButtonLabel;
}

- (void)initUI {
    
    [self.view addSubview:self.timeLabel];
    if (iPhone4) {
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.draw.mas_bottom).with.offset(10);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(self.timeLabel);
            make.height.mas_equalTo(self.timeLabel);
        }];
    } else {
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.draw.mas_bottom).with.offset(35 * ADJUSTHEIGHT);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(self.timeLabel);
            make.height.mas_equalTo(self.timeLabel);
        }];
    }
    
    [self.view addSubview:self.recordRemainTimeLabel];
    [self.recordRemainTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).with.offset(15  * ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.timeLabel.mas_centerX);
        make.width.mas_equalTo(self.recordRemainTimeLabel);
        make.height.mas_equalTo(self.recordRemainTimeLabel);
    }];
    
    [self.view addSubview:self.recordBtn];
    if (iPhone4) {
        self.recordBtn.layer.cornerRadius = 28;
        self.recordBtn.layer.masksToBounds = YES;
        [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.recordRemainTimeLabel.mas_bottom).with.offset(15 * ADJUSTHEIGHT);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.height.mas_equalTo(56);
            make.width.mas_equalTo(56);
        }];
    } else {
        self.recordBtn.layer.cornerRadius = 44 * ADJUSTHEIGHT;
        self.recordBtn.layer.masksToBounds = YES;
        [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.recordRemainTimeLabel.mas_bottom).with.offset(15 * ADJUSTHEIGHT);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.height.mas_equalTo(88  * ADJUSTHEIGHT);
            make.width.mas_equalTo(88  * ADJUSTHEIGHT);
        }];
    }
    
    [self.view addSubview:self.recordBtnLabel];
    [self.recordBtnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.recordBtn.mas_centerX);
        make.top.mas_equalTo(self.recordBtn.mas_bottom).with.offset(5 * ADJUSTHEIGHT);
        make.height.mas_equalTo(self.recordBtnLabel);
        make.width.mas_equalTo(self.recordBtnLabel);
    }];
    
    [self.view addSubview:self.stopRecordBtn];
    self.stopRecordBtn.layer.cornerRadius = 25 * ADJUSTHEIGHT;
    self.stopRecordBtn.layer.masksToBounds = YES;
    [self.stopRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.recordBtn.mas_left).with.offset(-30  * ADJUSTHEIGHT);
        make.centerY.mas_equalTo(self.recordBtn.mas_centerY);
        make.height.mas_equalTo(50  * ADJUSTHEIGHT);
        make.width.mas_equalTo(50  * ADJUSTHEIGHT);
    }];
    
    [self.view addSubview:self.stopRecordBtnLabel];
    [self.stopRecordBtnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.stopRecordBtn.mas_centerX);
        make.top.mas_equalTo(self.stopRecordBtn.mas_bottom).with.offset(5  * ADJUSTHEIGHT);
        make.height.mas_equalTo(self.stopRecordBtnLabel);
        make.width.mas_equalTo(self.stopRecordBtnLabel);
    }];
    
    [self.view addSubview:self.tagButton];
    self.tagButton.layer.cornerRadius = 25 * ADJUSTHEIGHT;
    self.tagButton.layer.masksToBounds = YES;
    [self.tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.recordBtn.mas_right).with.offset(30  * ADJUSTHEIGHT);
        make.centerY.mas_equalTo(self.recordBtn.mas_centerY);
        make.height.mas_equalTo(50  * ADJUSTHEIGHT);
        make.width.mas_equalTo(50  * ADJUSTHEIGHT);
    }];
    
    [self.view addSubview:self.tagButtonLabel];
    [self.tagButtonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tagButton.mas_centerX);
        make.top.mas_equalTo(self.tagButton.mas_bottom).with.offset(5);
        make.height.mas_equalTo(self.tagButtonLabel);
        make.width.mas_equalTo(self.tagButtonLabel);
    }];
}
@end
