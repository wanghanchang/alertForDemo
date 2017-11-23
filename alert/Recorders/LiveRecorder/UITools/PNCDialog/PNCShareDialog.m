//
//  PNCShareDialog.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/10.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCShareDialog.h"
#import "PNCDialogView.h"
#import "WXApi.h"

@protocol tapShareDelegate <NSObject>

- (void)tapped:(NSInteger)count;

@end

@interface ShareView : UIButton

- (instancetype)init;
@property (nonatomic,strong) UIImageView *upImg;
@property (nonatomic,strong) UILabel *downLabel;
@property (nonatomic,weak) id<tapShareDelegate> delegate;

@end

@implementation ShareView

- (instancetype)init {
    if (self = [super init]) {
        self.upImg = [[UIImageView alloc] init];
        self.downLabel = [[UILabel alloc] init];
        self.downLabel.font = [UIFont systemFontOfSize:13.0 * ADJUSTHEIGHT];
        self.upImg.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor= [UIColor clearColor];
        [self addSubview:self.upImg];
        [self addSubview:self.downLabel];
        self.userInteractionEnabled = YES;
        [self bk_whenTapped:^{
            [self.delegate tapped:self.tag];
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.upImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(44 * ADJUSTHEIGHT);
        make.width.mas_equalTo(44 * ADJUSTHEIGHT);
    }];
    
    [self.downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.upImg.mas_bottom).with.offset(5 * ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.equalTo(self.downLabel.mas_width);
        make.height.equalTo(self.downLabel.mas_height);
    }];
}

@end


@interface ShareEntity : NSObject
@property (nonatomic,copy) NSString* txt;
@property (nonatomic,copy) NSString* pic;
@property (nonatomic,assign) NSInteger type;
@end
@implementation ShareEntity
@end

@interface PNCShareDialogView : PNCDialogView

@property (nonatomic,copy) PNCDialogSharePickBlock block;
@property (nonatomic,strong) ShareView *shareView;
@property (nonatomic,strong) ShareView *shareView1;

@property (nonatomic,weak) PNCDialog *dialog;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) UIView *spliter1;
@property (nonatomic,strong) UIView *spliter2;
@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UIButton *cancelBtn;

@end

@implementation PNCShareDialogView

- (void)tapped:(NSInteger)count{
    self.block(self.dialog,count,0);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.title = [[UILabel alloc] init];
        self.title.text = @"分享到";
        self.title.font = [UIFont boldSystemFontOfSize:16.0];
        [self.containerView addSubview:self.title];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.containerView.mas_centerX);
            make.height.mas_equalTo(self.title);
            make.width.mas_equalTo(self.title);
            make.top.mas_equalTo(self.containerView.mas_top).with.offset(10);
        }];
        
        self.spliter1 = [UIView new];
        self.spliter1.backgroundColor = c_e0e0e0;
        [self.containerView addSubview:self.spliter1];
        [self.spliter1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.title.mas_bottom).with.offset(10);
            make.left.mas_equalTo(self.containerView.mas_left);
            make.height.mas_equalTo(0.5);
            make.right.mas_equalTo(self.containerView.mas_right);
        }];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelBtn.backgroundColor = [UIColor clearColor];
        [self.cancelBtn setTitleColor:c_888888 forState:UIControlStateNormal];
        [self.cancelBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.cancelBtn bk_whenTapped:^{
            self.block(_dialog,-1,1);
        }];
        
        [self.containerView addSubview:self.cancelBtn];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.containerView.mas_bottom);
            make.centerX.mas_equalTo(self.containerView.mas_centerX);
            make.width.mas_equalTo(88);
            make.height.mas_equalTo(44 * ADJUSTHEIGHT);
        }];
        
        self.spliter2 = [UIView new];
        self.spliter2.backgroundColor = c_e0e0e0;
        [self.containerView addSubview:self.spliter2];
        [self.spliter2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.cancelBtn.mas_top);
            make.left.mas_equalTo(self.containerView.mas_left);
            make.right.mas_equalTo(self.containerView.mas_right);
            make.height.mas_equalTo(0.5);
        }];
        
        NSMutableArray *shareEntityArray = [[NSMutableArray alloc] init];
   
        
        if ([WXApi isWXAppInstalled]) {
            ShareEntity *entity0 = [[ShareEntity alloc] init];
            entity0.txt = @"微信好友";
            entity0.pic = @"share_wechat";
            entity0.type = Share_Wechat_Friend;
            [shareEntityArray addObject:entity0];
            ShareEntity *entity1 = [[ShareEntity alloc] init];
            entity1.txt = @"朋友圈";
            entity1.pic = @"share_friends";
            entity1.type = Share_Wechat_myFriends;
            [shareEntityArray addObject:entity1];
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqqapi://"]]) {
            ShareEntity *entity2 = [[ShareEntity alloc] init];
            entity2.txt = @"QQ好友";
            entity2.pic = @"share_qq";
            entity2.type = Share_QQ_Friend;
            [shareEntityArray addObject:entity2];
            
            ShareEntity *entity3 = [[ShareEntity alloc] init];
            entity3.txt = @"QQ空间";
            entity3.pic = @"share_qq_zone";
            entity3.type = Share_QQ_Zone;
            [shareEntityArray addObject:entity3];
        }
        ShareEntity *entity4 = [[ShareEntity alloc] init];
        entity4.txt = @"复制链接";
        entity4.pic = @"share_copy";
        entity4.type = Share_Copy;
        [shareEntityArray addObject:entity4];
        
        
        if (shareEntityArray.count == 5) {
            for (int i = 0; i < shareEntityArray.count; i++) {
                ShareEntity *entity = shareEntityArray[i];
                if (i < 3) {
                    self.shareView = [[ShareView alloc] init];;
                    self.shareView.tag = entity.type;
                    self.shareView.delegate = (id)self;
                    self.shareView.upImg.image = [UIImage imageNamed:entity.pic];
                    self.shareView.downLabel.text = entity.txt;
                    [self.containerView addSubview:self.shareView];
                    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.spliter1.mas_bottom).with.offset(10 * ADJUSTHEIGHT);
                        make.left.mas_equalTo(self.mas_left).with.offset(frame.size.width / 3 * i);
                        make.height.mas_equalTo(66 * ADJUSTHEIGHT);
                        make.width.mas_equalTo((frame.size.width) / 3);
                    }];
                } else {
                    self.shareView1 = [[ShareView alloc] init];;
                    self.shareView1.tag = entity.type;
                    self.shareView1.delegate = (id)self;
                    self.shareView1.upImg.image = [UIImage imageNamed:entity.pic];
                    self.shareView1.downLabel.text = entity.txt;
                    [self.containerView addSubview:self.shareView1];
                    [self.shareView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.shareView.mas_bottom).with.offset(10 * ADJUSTHEIGHT);
                        make.left.mas_equalTo(self.containerView.mas_left).with.offset(frame.size.width / 3 * (i - 3));
                        make.height.mas_equalTo(66 * ADJUSTHEIGHT);
                        make.width.mas_equalTo((frame.size.width) / 3);
                    }];
                }
            }
        } else {
            for (int i = 0; i < shareEntityArray.count; i++) {
                ShareEntity *entity = shareEntityArray[i];
                self.shareView = [[ShareView alloc] init];;
                self.shareView.tag = entity.type;
                self.shareView.delegate = (id)self;
                self.shareView.upImg.image = [UIImage imageNamed:entity.pic];
                self.shareView.downLabel.text = entity.txt;
                [self.containerView addSubview:self.shareView];
                [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.spliter1.mas_bottom).with.offset(10);
                    make.left.mas_equalTo(self.mas_left).with.offset(frame.size.width / shareEntityArray.count * i);
                    make.height.mas_equalTo(self.shareView.mas_height);
                    make.width.mas_equalTo((frame.size.width) / shareEntityArray.count);
                    
                }];
            }
        }
        
    }
    return self;
}

@end

@implementation PNCShareDialog

+ (instancetype)initWithPickedBlock:(PNCDialogSharePickBlock)block {
    
    PNCShareDialog* dialog = [[PNCShareDialog alloc] init];
    PNCShareDialogView *shareDialogView;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqqapi://"]] && [WXApi isWXAppInstalled]) {
         shareDialogView = [[PNCShareDialogView alloc] initWithFrame:CGRectMake(0, 0, 320 * ADJUSTWIDTH, 360 * ADJUSTHEIGHT)];
    } else {
        if (iPhone4) {
            shareDialogView = [[PNCShareDialogView alloc] initWithFrame:CGRectMake(0, 0, 320 * ADJUSTWIDTH, 280 * ADJUSTHEIGHT)];
        } else {
            shareDialogView = [[PNCShareDialogView alloc] initWithFrame:CGRectMake(0, 0, 320 * ADJUSTWIDTH, 245 * ADJUSTHEIGHT)];
        }
    }
    
    dialog.hideWhenTouchUpOutside = YES;
    shareDialogView.block = block;
    shareDialogView.dialog = dialog;
    dialog.contentView = shareDialogView;
    
    return dialog;
}

@end
