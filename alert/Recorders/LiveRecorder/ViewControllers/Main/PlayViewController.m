//
//  PlayViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/13.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PlayViewController.h"
#import "WaveScrollView.h"
#import "RecordFileEditInfoAlert.h"
#import "NSString+Trim.h"
#import "OrdersRequest.h"
#import "GTMBase64.h"
#import "TranslateTxtViewController.h"
#import "RecordUploadOrShare.h"
#import "PNCShareDialog.h"
#import "OrderStateViewController.h"
#import "RecordTextView.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import "RecordTextView.h"

#define Tag_Trans   1000
#define Tag_Copy     999

typedef struct Wavehead
{
    /****RIFF WAVE CHUNK*/
    unsigned char a[4];     //四个字节存放'R','I','F','F'
    long int b;             //整个文件的长度-8;每个Chunk的size字段，都是表示除了本Chunk的ID和SIZE字段外的长度;
    unsigned char c[4];     //四个字节存放'W','A','V','E'
    /****RIFF WAVE CHUNK*/
    /****Format CHUNK*/
    unsigned char d[4];     //四个字节存放'f','m','t',''
    long int e;             //16后没有附加消息，18后有附加消息；一般为16，其他格式转来的话为18
    short int f;            //编码方式，一般为0x0001;
    short int g;            //声道数目，1单声道，2双声道;
    int h;                  //采样频率;
    unsigned int i;         //每秒所需字节数;
    short int j;            //每个采样需要多少字节，若声道是双，则两个一起考虑;
    short int k;            //即量化位数
    /****Format CHUNK*/
    /***Data Chunk**/
    unsigned char p[4];     //四个字节存放'd','a','t','a'
    long int q;             //语音数据部分长度，不包括文件头的任何部分
} WaveHead;//定义WAVE文件的文件头结构体

static AVAudioPlayer *_player;

@interface PlayViewController ()<AVAudioPlayerDelegate,WaveViewDidChangeDelegate,UIScrollViewDelegate>

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic,strong) WaveScrollView *waveView;

@property (nonatomic,strong) NSMutableData *waveData;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *txt_path;

@property (nonatomic,strong) UILabel *leftTopLabel;
@property (nonatomic,strong) UIButton *rightTopButton;

@property (nonatomic,strong) UIButton *beginBtn;
@property (nonatomic,strong) UILabel *beiginLabel;

@property (nonatomic,strong) UIImageView *renameImg;
@property (nonatomic,strong) UILabel *renameLabel;

@property (nonatomic,strong) UIImageView *tagImg;
@property (nonatomic,strong) UILabel *tagLabel;

@property (nonatomic,strong) UIImageView *deleteImg;
@property (nonatomic,strong) UILabel *deleteLabel;

@property (nonatomic,strong) UIImageView *shareImg;
@property (nonatomic,strong) UILabel *shareLabel;

@property (nonatomic,strong) UIScrollView *backScroll;

@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) RecordTextView *recordTextView;
@property (nonatomic,strong) UIImageView *noImgView;

@property (nonatomic,strong) UIView *topLine;


@property (nonatomic,copy) NSMutableString *transString;
@property (nonatomic,strong) CTCallCenter *callCenter;  //必须在这里声明，要不不会回调block

@end

@implementation PlayViewController

- (instancetype)initWithFileName:(EntityLiveRecord *)entity {
    if (self = [super init]) {
        NSString *p =  [CommonUtils generateFilePathWithFileName:entity.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:NO];
        _path = [p stringByAppendingString:@".wav"];
        _txt_path = [CommonUtils generateFilePathWithFileName:entity.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:YES];
        self.entity = entity;
        return self;
    }
    return nil;
}

- (UILabel *)leftTopLabel {
    if (!_leftTopLabel) {
        _leftTopLabel = [UILabel new];
        _leftTopLabel.text = @"录音转文字";
        _leftTopLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _leftTopLabel;
}


-(void)pageControlChanged:(UIPageControl *)pageControl {//设置滚动偏移量(屏幕左上角距离坐标原点的偏移量)
    CGFloat xlen = _pageControl.currentPage * SCREENWIDTH;
    [_backScroll setContentOffset:CGPointMake(xlen, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x / self.view.frame.size.width;
    [_pageControl setCurrentPage:currentPage];
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = c_e0e0e0;
    }
    return _topLine;
}

+ (AVAudioPlayer *)player {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[AVAudioPlayer alloc] init];
    });
    return _player;
}

- (void)registerForNotifications {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isPlaying:) name:@"isPlaying" object:nil];
}

- (void)isPlaying:(NSNotification*)noti {
    //刷新UI;
    [self runInMainQueue:^{
        self.beginBtn.selected = NO;
    }];
}

//重新刷新加载已经转完的数据
- (void)reloadTranslate {
    [_backScroll setContentOffset:CGPointMake(SCREENWIDTH, 0) animated:NO];
    [self dealFileId];
}

- (void)dealCallDataInPlaying {
    [self runAfterSecs:.2 block:^{
        if ([_player isPlaying]) {
            float time = [[PlayViewController player] currentTime];
            self.waveView.link.paused = YES;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:time] forKey:@"isPlaying"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak PlayViewController *ws = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler=^(CTCall* call){
        if([call.callState isEqualToString:CTCallStateDisconnected]) {
            DLog(@"Call has been disconnected");
        } else if([call.callState isEqualToString:CTCallStateConnected]) {
            DLog(@"Callhasjustbeen connected");
        } else if([call.callState isEqualToString:CTCallStateIncoming]) {
            DLog(@"Call is incoming");
            [ws dealCallDataInPlaying];
        } else if([call.callState isEqualToString:CTCallStateDialing]) {
            DLog(@"Call is Dialing");
            [ws dealCallDataInPlaying];
        } else {
            DLog(@"Nothing is done");
        }
    };
        
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.topLine];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.view addSubview:self.leftTopLabel];
    [self.leftTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.left.mas_equalTo(self.view.mas_left).with.offset(10);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(self.leftTopLabel);
    }];
    
    [self.view addSubview:self.rightTopButton];
    [self.rightTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64 + 9);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-10);
        make.width.mas_equalTo(self.rightTopButton.mas_width);
        make.height.mas_equalTo(26);
    }];
    
    _backScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,64 + 44, self.view.frame.size.width, MUSICHEIGHT)];
    [_backScroll setContentSize:CGSizeMake(SCREENWIDTH * 2, 0)];
    [_backScroll setPagingEnabled:YES];
    [_backScroll setShowsHorizontalScrollIndicator:YES];
    _backScroll.delegate = self;
    [self.view addSubview:_backScroll];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"lll" ofType:@"wav"];
    self.waveView = [[WaveScrollView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, MUSICHEIGHT) withPath:_path andInfoFilePath:_txt_path timeLong:self.entity.timeLong];
    self.waveView.delegate = self;
    [_backScroll addSubview:self.waveView];
    
    
    self.recordTextView = [[RecordTextView alloc] initWithFrame:CGRectMake(SCREENWIDTH,0, SCREENWIDTH, MUSICHEIGHT)];
    self.recordTextView.editable = NO;
    [_backScroll addSubview:self.recordTextView];
    self.noImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH,0, SCREENWIDTH, MUSICHEIGHT)];
    self.noImgView.image = [UIImage imageNamed:@"no_translate"];
    self.noImgView.contentMode = UIViewContentModeCenter;
    self.noImgView.hidden = YES;
    [_backScroll addSubview:self.noImgView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,64 + MUSICHEIGHT + 10 , SCREENWIDTH, 12)];
    [_pageControl setNumberOfPages:2];
    [_pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];    
    _pageControl.pageIndicatorTintColor = c_666666;// 设置非选中页的圆点颜色
    _pageControl.currentPageIndicatorTintColor = RedColor;
    [self.view addSubview:_pageControl];
    
    if (self.seeTranslate == YES) {
        [_backScroll setContentOffset:CGPointMake(SCREENWIDTH, 0) animated:NO];
    }

    NSError *err;
    if ([_player isPlaying]) {
        [_player stop];
    }

    
   _player = [[PlayViewController player]  initWithContentsOfURL:[NSURL URLWithString:_path] error:&err];
    _player.delegate = self;
    _player.volume = 0.8;//0.0~1.0之间
    [_player prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    self.duration = [_player duration];
    self.title = @"播放";
    self.view.backgroundColor = WhiteColor;
    
    [self initUI];
    
    
//填充tagInfo数据
    self.waveView.d.tagInfoArray = [NSMutableArray arrayWithCapacity:5];
    self.waveView.infoDic = [NSMutableDictionary dictionaryWithDictionary:[CommonUtils getJsonDataToDicByPath:_txt_path]];
    [self.waveView.infoDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TagInfo *info = [[TagInfo alloc] init];
        info.sec = [key intValue];
        info.info = [NSString stringWithString:obj];
        [self.waveView.d.tagInfoArray addObject:info];
    }];

    
//重命名点击
    self.renameImg.userInteractionEnabled = YES;
    [self.renameImg bk_whenTapped:^{
        LiveRecordHelper *helper = [LiveRecordHelper helper];
        TagAlertObj *obj = [[TagAlertObj alloc] init];
        obj.tagName = _entity.recordTag;
        obj.tagColor = _entity.recordTagColor;
        obj.recordName = _entity.userNamedFile;
        RecordFileEditInfoAlert *alert =  [[RecordFileEditInfoAlert alloc] initWithFrame:CGRectMake(40 * ADJUSTWIDTH , SCREENHEIGHT / 4, (SCREENWIDTH - (80 * ADJUSTWIDTH)), 300 * ADJUSTHEIGHT) WithCancelName:@"取消" WithObj:obj WithBlock:^(RecordFileEditInfoAlert *myAlert, int buttonindex, TagAlertObj *obj) {
            
            if (buttonindex == 1) {
                if (obj.recordName.length == 0) {
                    _entity.userNamedFile = @"未命名";
                } else {
                    _entity.userNamedFile = obj.recordName;
                }
                _entity.recordTagColor = obj.tagColor;
                _entity.recordTag = obj.tagName;
                [helper updateEntity:_entity forEntityId:_entity.entityId];
            }
            [myAlert hide];
        }];
        [alert show];
    }];
  
    
//标记点击
    self.tagImg.userInteractionEnabled = YES;
    [self.tagImg bk_whenTapped:^{
            TagInfo *info = [[TagInfo alloc] init];
            info.sec = (int)ceilf([_player currentTime] * 30);
            info.info = @"标记";
            info.isNew = YES;
        
        __block BOOL canAdd = YES;
        [self.waveView.d.tagInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TagInfo *i = (TagInfo*)obj;
            if (abs(i.sec - info.sec) < 60) {
                canAdd = NO;
                *stop = YES;
            }
        }];
        if (canAdd == YES) {
            [self.waveView.d.tagInfoArray addObject:info];
            [self.waveView.d setNeedsDisplay];
        } else {
            UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,300,120,30)];
            hintLabel.backgroundColor = c_000000;
            hintLabel.alpha = 0.0;
            hintLabel.text = @"2s内无文字";
            hintLabel.textColor = WhiteColor;
            hintLabel.layer.cornerRadius = 2;
            hintLabel.layer.masksToBounds = YES;
            [self.view addSubview:hintLabel];
            [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view.mas_centerX);
                make.bottom.mas_equalTo(self.pageControl.mas_top).with.offset(-10);
                make.height.mas_equalTo(hintLabel.mas_height);
                make.width.mas_equalTo(hintLabel.mas_width);
            }];
            [UIView animateWithDuration:1.0 animations:^{
                hintLabel.alpha = 0.75;
            } completion:^(BOOL finished){
                [hintLabel removeFromSuperview];
            }];
        }
    }];
    
    
    self.deleteImg.userInteractionEnabled = YES;
    [self.deleteImg bk_whenTapped:^{
        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"确定删除吗?" containsButtonTitles:@[@"确定",@"取消"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
            if (buttonIndex == 0) {
                LiveRecordHelper *helper = [LiveRecordHelper helper];
                [helper remove:self.entity.entityId];
                [self.navigationController popViewControllerAnimated:YES];
                [CommonUtils delteFilehWithFileName:_entity.fileName andFileManagerName:[[AccountInfo shareInfo] mobile]];
            }
            [dialog hide];
        }] show];
    }];
    
    [self.rightTopButton bk_whenTapped:^{
        
        if (self.rightTopButton.tag == Tag_Trans) {
            OrderStateViewController *os = [[OrderStateViewController alloc] initWithEntity:self.entity];
            [self.navigationController pushViewController:os animated:YES];
        } else {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.recordTextView.text;
            
            UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,300,120,30)];
            hintLabel.backgroundColor = c_000000;
            hintLabel.alpha = 0.0;
            hintLabel.text = @"已复制!";
            hintLabel.textColor = WhiteColor;
            hintLabel.layer.cornerRadius = 2;
            hintLabel.layer.masksToBounds = YES;
            [self.view addSubview:hintLabel];
            [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view.mas_centerX);
                make.bottom.mas_equalTo(self.pageControl.mas_top).with.offset(-10);
                make.height.mas_equalTo(hintLabel.mas_height);
                make.width.mas_equalTo(hintLabel.mas_width);
            }];
            [UIView animateWithDuration:1.0 animations:^{
                hintLabel.alpha = 0.75;
            } completion:^(BOOL finished){
                [hintLabel removeFromSuperview];
            }];
        }
        
    }];
    
    self.shareImg.userInteractionEnabled = YES;
    [self.shareImg bk_whenTapped:^{
        [[PNCShareDialog initWithPickedBlock:^(PNCDialog *dialog, NSInteger pickedCount ,NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [dialog hide];
            } else {
                if (self.entity.isFinishUplaod) {
                    [self getShareUrlByFilId:self.entity withPickedCount:pickedCount];
                } else {
                    [self goUplpad:self.entity withPickedCount:pickedCount];
                }
                [dialog hide];
            }
        }] show];
    }];
    
    if (self.entity.isFinishUplaod ==YES) {
        [self dealFileId];
    } else {
        self.noImgView.hidden = NO;
    }
    
}

//只需要在当前使用的控制器中重写这两个方法就可以了，第一次push进来的时候两个方法都会调用，parent的值不为空。当开始使用系统侧滑的时候，会先调用willMove，而parent的值为空；当滑动结束后返回了上个页面，则会调用didMove，parent的值也为空，如果滑动结束没有返回上个页面，也就是轻轻划了一下还在当前页面，那么则不会调用didMove方法。
//所以如果想要在侧滑返回后在上个页面做一些操作的话，可以在didMove方法中根据parent的值来判断。

- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    if (!parent) {
//        说明将要回退
        if ([_player isPlaying]) {
            [_player stop];
            [self.waveView.link invalidate];
        }
        
        self.waveView.infoDic = [NSMutableDictionary dictionaryWithCapacity:5];
        for (TagInfo *info in self.waveView.d.tagInfoArray) {
            [self.waveView.infoDic setObject:info.info forKey:[NSString stringWithFormat:@"%d",info.sec]];
        }
        BOOL isWrite = [CommonUtils writeJsonDataFromDictionaryByPath:_txt_path withDic:self.waveView.infoDic];
        if (isWrite) {
            DLog(@"finish");
        }
        

    }
    DLog(@"%s,%@",__FUNCTION__,parent);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    DLog(@"%s,%@",__FUNCTION__,parent);
    if(!parent){
        DLog(@"页面pop成功了");
    }
}



- (void)goUplpad:(EntityLiveRecord *)liveRecord withPickedCount:(Share_Type)pickedCount {
    
    __weak PlayViewController *ws = self;
    PNCProgressDialog *dialog = [PNCProgressDialog progressWithTitle:@"" andCommitBlock:^(PNCDialog *dialog) {
        [UpLoadTranslate translate].stop = YES;
        [dialog hide];
    }];
    [dialog show];
    
    RecordUploadOrShare *upload = [[RecordUploadOrShare alloc] init];
    [upload checkUserNetTouploadWithEntity:liveRecord withState:^(UpDateState upState, float progress) {
        PNCProgressViewAlert *progressDialogView = (PNCProgressViewAlert*)dialog.contentView;
        if (upState == Up_ing) {
            [self runInMainQueue:^{
                progressDialogView.progressView.progress = progress;
                progressDialogView.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress * 100];
            }];
        }
        if (upState == Up_done) {
            progressDialogView.label.text = @"已完成";
            [dialog hide];
            [ws getShareUrlByFilId:liveRecord withPickedCount:pickedCount];
        }
        if (upState == Up_fail) {
            [dialog hide];
        }
    } WithUserCancel:^(BOOL isCancel) {
        if (isCancel ) {
            [dialog hide];
        }
    }];
    
}

- (void)getShareUrlByFilId:(EntityLiveRecord *)record withPickedCount:(Share_Type)pickedCount {
    
    __weak PlayViewController *ws = self;
    [RecordUploadOrShare goShareWithEntity:record WithReturnKey:^(int a, NSString *shareUrl) {
        if (a == HTTP_OK) {
            if (pickedCount == 4) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = shareUrl;
                UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,300,120,30)];
                hintLabel.backgroundColor = c_000000;
                hintLabel.alpha = 0.0;
                hintLabel.text = @"已复制链接";
                hintLabel.textColor = WhiteColor;
                hintLabel.layer.cornerRadius = 2;
                hintLabel.layer.masksToBounds = YES;
                [self.view addSubview:hintLabel];
                [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view.mas_centerX);
                    make.bottom.mas_equalTo(self.pageControl.mas_top).with.offset(-10);
                    make.height.mas_equalTo(hintLabel.mas_height);
                    make.width.mas_equalTo(hintLabel.mas_width);
                }];
                [UIView animateWithDuration:1.0 animations:^{
                    hintLabel.alpha = 0.75;
                } completion:^(BOOL finished){
                    [hintLabel removeFromSuperview];
                }];
                return ;
            }
            if (pickedCount < 2) {
                [WechatQQRequest goWechatShare:pickedCount WithUrl:shareUrl];
                return;
            }
            if (pickedCount == Share_QQ_Zone || pickedCount == Share_QQ_Friend) {
                [WechatQQRequest goQQShare:pickedCount WithUrl:shareUrl];
            }
        }        
        if (a == FILE_INVALIDATE) {
            [ws goUplpad:record withPickedCount:pickedCount];
        }
    }];
    
    
}

- (void)dealFileId {
    if (self.entity.translateState == 2 && self.entity.resultTransStr.length > 0) {
        _transString = [NSMutableString stringWithString:self.entity.resultTransStr];
        [self setLabelText];
        [_rightTopButton setTitle:@"点击复制到剪贴板" forState:UIControlStateNormal];
        _rightTopButton.tag = Tag_Copy;
        self.noImgView.hidden = YES;
    } else {
        self.noImgView.hidden = NO;
        if (self.entity.fileId == nil || [self.entity.fileId trimAll].length == 0) {
            [_rightTopButton setTitle:@"转文字" forState:UIControlStateNormal];
            _rightTopButton.tag = Tag_Trans;
        } else {
            [[OrdersRequest sharedRequest] getTranslateStateByFileId:self.entity.fileId WithReturnBlock:^(int a, int isTrans, NSString *orderId, NSString *transText) {
                if (isTrans == 1) {
                    self.noImgView.hidden = YES;
                    [_rightTopButton setTitle:@"点击复制到剪贴板" forState:UIControlStateNormal];
                    _rightTopButton.tag = Tag_Copy;
                    NSData *data = [GTMBase64 decodeString:transText];
                    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    _transString = [NSMutableString string];
                    if (array.count > 0) {
                        for (NSDictionary *dic in array) {
                            TranslateEntity *entity = [[TranslateEntity alloc] init];
                            entity.bg = dic[@"bg"];
                            entity.ed = dic[@"ed"];
                            entity.speaker = dic[@"speaker"];
                            entity.onebest = dic[@"onebest"];
                            [_transString appendString:entity.onebest];
                        }
                    } else {
                        _transString = [NSMutableString stringWithString:@"空"];
                    }
                    self.entity.translateState = 2;
                    self.entity.resultTransStr =_transString;
                    [[LiveRecordHelper helper] updateEntity:self.entity forEntityId:self.entity.entityId];
                    [self setLabelText];
                }
                if (isTrans == 0) {
                    [_rightTopButton setTitle:@"转文字" forState:UIControlStateNormal];
                    _rightTopButton.tag = Tag_Trans;
                    if ([orderId trim].length == 0 || orderId == nil) {
                    } else {
                    }
                }
            }];
        }
    }
}

- (void)setLabelText {
    self.recordTextView.textColor = c_333333;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping; //结尾部分以什么方式省略
    paraStyle.alignment = NSTextAlignmentLeft; //文本对齐方式
    paraStyle.lineSpacing = 10; //字体间距
    paraStyle.firstLineHeadIndent = 0.0; //首行缩进
    paraStyle.paragraphSpacingBefore = 0.0; //段首行空白空间
    paraStyle.headIndent = 0; //整体缩进(首行除外)
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSKernAttributeName:@1.5f, NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:_transString attributes:dic];
    self.recordTextView.attributedText = attributeStr;
}


- (void)begin:(UIButton*)btn {
    if (btn.selected) {
        _beiginLabel.text = @"开始播放";
        self.waveView.link.paused = YES;
        [_player pause];//播放
    } else {
        _beiginLabel.text = @"暂停";
        self.waveView.link.paused = NO;
        [_player play];//播放
    }
    btn.selected = !btn.selected;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.waveView.link setPaused:YES];
    [self.waveView initPlayData];
    _beginBtn.selected = NO;
    _beiginLabel.text = @"开始播放";
//    _beginBtn.selected = !_beginBtn.selected;
}

- (void)waveChangeTimeToPlay:(float)currentTime {
    if (currentTime < 1.0) {
        [_player setCurrentTime:[_player duration] * currentTime];
    } else {
        [_player setCurrentTime:0];
        [self.waveView initPlayData];
        [self.waveView setNeedsDisplay];
    }
}

- (void)waveDidPaused:(BOOL)paused {
    if (paused) {
        if (_player.isPlaying) {
            [_player pause];
            _beginBtn.selected = YES;
            _beiginLabel.text = @"开始播放";
            _beginBtn.selected = !_beginBtn.selected;
        }
    } else {
        if (!_player.isPlaying) {
            [_player play];
            _beginBtn.selected = YES;
            _beiginLabel.text = @"暂停";
            _beginBtn.selected = !_beginBtn.selected;
        }
    }
}


- (void)dealloc {
    free(self.waveView.d.drawRealBuffer);
    self.waveView.d.drawRealBuffer = NULL;
}

- (void)initUI {
    [self.view addSubview:self.beginBtn];
    [self.beginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waveView.mas_bottom).with.offset(30 * ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(66);
        make.width.mas_equalTo(66);
    }];
    
    [self.view addSubview:self.beiginLabel];
    [self.beiginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.beginBtn.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.beginBtn.mas_centerX);
        make.height.mas_equalTo(self.beiginLabel);
        make.width.mas_equalTo(self.beiginLabel);
    }];
    
    [self.view addSubview:self.renameImg];
    [self.renameImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.beginBtn.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left).with.offset(20 * ADJUSTWIDTH);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(34);
    }];
    
    [self.view addSubview:self.renameLabel];
    [self.renameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.renameImg.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.renameImg.mas_centerX);
        make.height.mas_equalTo(self.renameLabel);
        make.width.mas_equalTo(self.renameLabel);
    }];
    
    [self.view addSubview:self.tagImg];
    [self.tagImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.renameImg.mas_top);
        make.left.mas_equalTo(self.renameImg.mas_right).with.offset(30 * ADJUSTWIDTH);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(34);
    }];
    
    [self.view addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagImg.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.tagImg.mas_centerX);
        make.height.mas_equalTo(self.tagLabel);
        make.width.mas_equalTo(self.tagLabel);
    }];
    
    [self.view addSubview:self.shareImg];
    [self.shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.renameImg.mas_top);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-20 * ADJUSTWIDTH);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(34);
    }];
    
    [self.view addSubview:self.shareLabel];
    [self.shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareImg.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.shareImg.mas_centerX);
        make.height.mas_equalTo(self.shareLabel);
        make.width.mas_equalTo(self.shareLabel);
    }];
    
    [self.view addSubview:self.deleteImg];
    [self.deleteImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.renameImg.mas_top);
        make.right.mas_equalTo(self.shareImg.mas_left).with.offset(-30 * ADJUSTWIDTH);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(34);
    }];
    
    [self.view addSubview:self.deleteLabel];
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteImg.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(self.deleteImg.mas_centerX);
        make.height.mas_equalTo(self.deleteLabel);
        make.width.mas_equalTo(self.deleteLabel);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)rightTopButton {
    if (!_rightTopButton) {
        _rightTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightTopButton setTitle:@"转文字" forState:UIControlStateNormal];
        _rightTopButton.titleLabel.font = FONT_MEDIUM(15.0);
        _rightTopButton.tag = Tag_Trans;
        [_rightTopButton setContentEdgeInsets:UIEdgeInsetsMake(1, 10, 1, 10)];
        [_rightTopButton setBackgroundImage:[UIColor imageFromHexString:@"#fd6a66"] forState:UIControlStateNormal];
        [_rightTopButton setBackgroundImage:[UIColor imageFromHexString:@"#666666"] forState:UIControlStateDisabled];
        _rightTopButton.layer.cornerRadius = 5.0;
        _rightTopButton.layer.masksToBounds = YES;
    }
    return _rightTopButton;
}

- (UIButton *)beginBtn {
    if (!_beginBtn) {
        _beginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beginBtn setBackgroundColor:RedColor];
        [_beginBtn setBackgroundImage:[UIImage imageNamed:@"play_begin"] forState:UIControlStateNormal];
        [_beginBtn setBackgroundImage:[UIImage imageNamed:@"playVC_fault"] forState:UIControlStateSelected];
        [_beginBtn addTarget:self action:@selector(begin:) forControlEvents:UIControlEventTouchUpInside];
        _beginBtn.layer.cornerRadius = 33.0;
        _beginBtn.layer.masksToBounds = YES;
    }
    return _beginBtn;
}

- (UILabel *)beiginLabel {
    if (!_beiginLabel) {
        _beiginLabel = [UILabel new];
        _beiginLabel.textColor = c_666666;
        _beiginLabel.font = [UIFont systemFontOfSize:12.0];
        _beiginLabel.text = @"开始播放";
    }
    return _beiginLabel;
}

- (UILabel *)renameLabel {
    if (!_renameLabel) {
        _renameLabel = [UILabel new];
        _renameLabel.textColor = c_666666;
        _renameLabel.font = [UIFont systemFontOfSize:12.0];
        _renameLabel.text = @"重命名";
    }
    return _renameLabel;
}
- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [UILabel new];
        _deleteLabel.textColor = c_666666;
        _deleteLabel.font = [UIFont systemFontOfSize:12.0];
        _deleteLabel.text = @"删除";
    }
    return _deleteLabel;
}
- (UILabel *)shareLabel {
    if (!_shareLabel) {
        _shareLabel = [UILabel new];
        _shareLabel.textColor = c_666666;
        _shareLabel.font = [UIFont systemFontOfSize:12.0];
        _shareLabel.text = @"分享";
    }
    return _shareLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.text = @"标记";
        _tagLabel.textColor = c_666666;
        _tagLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _tagLabel;
}

- (UIImageView *)renameImg {
    if (!_renameImg) {
        _renameImg = [[UIImageView alloc] init];
        [_renameImg setBackgroundColor:c_FF9A47];
        _renameImg.image = [UIImage imageNamed:@"playVC_rename"];
        _renameImg.layer.cornerRadius = 17.0;
        _renameImg.contentMode = UIViewContentModeCenter;
        _renameImg.layer.masksToBounds = YES;
    }
    return _renameImg;
}

- (UIImageView *)tagImg {
    if (!_tagImg) {
        _tagImg =  [[UIImageView alloc] init];
        [_tagImg setBackgroundColor:c_fc5790];
        _tagImg.image = [UIImage imageNamed:@"playVC_tag"];
        _tagImg.contentMode = UIViewContentModeCenter;
        _tagImg.layer.cornerRadius = 17.0;
        _tagImg.layer.masksToBounds = YES;
    }
    return _tagImg;
}

- (UIImageView *)deleteImg {
    if (!_deleteImg) {
        _deleteImg = [[UIImageView alloc] init];
        [_deleteImg setBackgroundColor:RedColor];
        _deleteImg.image = [UIImage imageNamed:@"playVC_delete"];
        _deleteImg.contentMode = UIViewContentModeCenter;
        _deleteImg.layer.cornerRadius = 17.0;
        _deleteImg.layer.masksToBounds = YES;
    }
    return _deleteImg;
}

- (UIImageView *)shareImg {
    if (!_shareImg) {
        _shareImg = [[UIImageView alloc] init];
        [_shareImg setBackgroundColor:RedColor];
        _shareImg.image = [UIImage imageNamed:@"record_file_share"];
        _shareImg.contentMode = UIViewContentModeCenter;
        _shareImg.layer.cornerRadius = 17.0;
        _shareImg.layer.masksToBounds = YES;
    }
    return _shareImg;
}
@end
