//
//  PNCProgressDialog.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/6/4.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCProgressDialog.h"

@implementation PNCProgressViewAlert

- (instancetype)initWithFrame:(CGRect)frame {
 
    if(self = [super initWithFrame:frame]) {
        
        self.label = [[UILabel alloc] init];
        self.label.text = @"正在上传中音频文件";
        [self.containerView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_top).with.offset(7 * ADJUSTHEIGHT);
            make.centerX.mas_equalTo(self.containerView.mas_centerX);
            make.height.mas_equalTo(33);
            make.width.mas_equalTo(self.label.mas_width);
        }];
        
        
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = c_fd3a32;
        _progressView.trackTintColor = c_E6E6E6;
        _progressView.progress= 0.0;
        _progressView.layer.cornerRadius = 4;
        _progressView.layer.masksToBounds = YES;
        _progressView.progressViewStyle=UIProgressViewStyleBar;
        _progressView.progressViewStyle=UIProgressViewStyleDefault;
        [self.containerView addSubview:_progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.label.mas_bottom).with.offset(10 * ADJUSTHEIGHT);
            make.left.mas_equalTo(self.containerView.mas_left).with.offset(15);
            make.right.mas_equalTo(self.containerView.mas_right).with.offset(-15);
            make.height.mas_equalTo(6);
        }];
        
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = c_999999;
        _progressLabel.text = @"30%";
        [self.containerView addSubview:self.progressLabel];
        [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.progressView.mas_bottom).with.offset(7 * ADJUSTHEIGHT);
            make.centerX.mas_equalTo(self.containerView.mas_centerX);
            make.height.mas_equalTo(self.progressLabel.mas_height);
            make.width.mas_equalTo(self.progressLabel.mas_width);
        }];


        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelBtn.backgroundColor = [UIColor clearColor];
        [self.cancelBtn setTitleColor:c_888888 forState:UIControlStateNormal];
        [self.cancelBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.cancelBtn bk_whenTapped:^{
            self.block(_dialog);
        }];

        [self.containerView addSubview:self.cancelBtn];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.containerView.mas_bottom);
            make.centerX.mas_equalTo(self.containerView.mas_centerX);
            make.width.mas_equalTo(88);
            make.height.mas_equalTo(44);
        }];
        
        self.split = [UIView new];
        self.split.backgroundColor = c_cccccc;
        [self.containerView addSubview:self.split];
        [self.split mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.cancelBtn.mas_top);
            make.left.mas_equalTo(self.containerView.mas_left);
            make.right.mas_equalTo(self.containerView.mas_right);
            make.height.mas_equalTo(0.5);
        }];

        
        
        self.backgroundColor = WhiteColor;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        return self;
    }
    return nil;
}


@end


@implementation PNCProgressDialog

+ (instancetype)progressWithTitle:(NSString *)title
             andCommitBlock:(PNCProgressBlock)block {
    
    PNCProgressDialog* dialog = [[PNCProgressDialog alloc] init];
    
    PNCProgressViewAlert *progressDialogView = [[PNCProgressViewAlert alloc] initWithFrame:CGRectMake(0, 0, 320 * ADJUSTWIDTH, 200)];
    dialog.hideWhenTouchUpOutside = NO;
    progressDialogView.block = block;
    progressDialogView.dialog = dialog;
    dialog.contentView = progressDialogView;
    
    return dialog;
}


@end
