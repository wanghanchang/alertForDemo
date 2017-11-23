//
//  RecordFileTableViewCell.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/29.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "RecordFileTableViewCell.h"

#define Pic_Width  26
#define Pic_Width_Half 13

@implementation RecordFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self =  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.backView];
        [self.backView addSubview:self.midBackView];
        [self.midBackView addSubview:self.xxDotButton];
        [self.midBackView addSubview:self.shareImg];
        [self.midBackView addSubview:self.editImg];
        [self.midBackView addSubview:self.deleteImg];
        [self.midBackView addSubview:self.translateButton];

        [self.backView addSubview:self.topCardLabel];
        [self.backView addSubview:self.arrowImg];

        [self.backView addSubview:self.nameLabel];
        [self.backView addSubview:self.recordBeginLabel];
        [self.backView addSubview:self.recordTimeLabel];
    }
    return self;
}

- (UIView *)midBackView {
    if (!_midBackView) {
        _midBackView = [UIView new];
        _midBackView.backgroundColor = WhiteColor;
    }
    return _midBackView;
}

- (void)clickIt:(UIButton*)button {
    if (button.selected == NO) {
        button.selected = !button.selected;
        [UIView animateWithDuration:.5 animations:^{
            button.transform = CGAffineTransformMakeRotation(M_PI_2);
            [self.shareImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-50);
            }];
            
            [self.deleteImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-90);
            }];
            
            [self.editImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-130);
            }];
            self.translateButton.alpha = 0;
            self.shareImg.alpha = 1;
            self.editImg.alpha = 1;
            self.deleteImg.alpha = 1;
            [self.contentView layoutIfNeeded];
        }completion:^(BOOL finished) {
        }];
    } else if (button.selected == YES) {
        [UIView animateWithDuration:.5 animations:^{
            button.transform = CGAffineTransformMakeRotation(0);
            
            [self.shareImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-10);
            }];
            [self.editImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-10);
            }];
            [self.deleteImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-10);
            }];
            self.translateButton.alpha = 1;
            self.shareImg.alpha = 0;
            self.editImg.alpha = 0;
            self.deleteImg.alpha = 0;
            [self.contentView layoutIfNeeded];
        }completion:^(BOOL finished) {
            button.selected = !button.selected;
        }];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).with.insets(padding);
    }];
    
    [self.topCardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView.mas_top);
        make.left.mas_equalTo(self.backView.mas_left);
        make.right.mas_equalTo(self.backView.mas_right);
        make.height.mas_equalTo(40);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topCardLabel.mas_left).with.offset(10);
        make.centerY.mas_equalTo(self.shareImg.mas_centerY);
        make.width.mas_equalTo(120 * ADJUSTWIDTH);
        make.height.mas_equalTo(self.nameLabel);
    }];
    
    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topCardLabel.mas_right).with.offset(-10);
        make.top.mas_equalTo(self.topCardLabel.mas_top).with.offset(12.5);
        make.bottom.mas_equalTo(self.topCardLabel.mas_bottom).with.offset(-12.5);
        make.width.mas_equalTo(self.arrowImg);
    }];
    
    [self.midBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topCardLabel.mas_right).with.offset(-10);
        make.top.mas_equalTo(self.topCardLabel.mas_bottom).with.offset(10);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(self.nameLabel.mas_right).with.offset(10);
    }];
    
    [self.xxDotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-10);
        make.centerY.mas_equalTo(self.midBackView.mas_centerY);
        make.height.mas_equalTo(Pic_Width);
        make.width.mas_equalTo(Pic_Width);
    }];
    
    [self.shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-50);
        make.centerY.mas_equalTo(self.midBackView.mas_centerY);
        make.height.mas_equalTo(Pic_Width);
        make.width.mas_equalTo(Pic_Width);
    }];
    
    [self.deleteImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-90);
        make.centerY.mas_equalTo(self.midBackView.mas_centerY);
        make.height.mas_equalTo(Pic_Width);
        make.width.mas_equalTo(Pic_Width);
    }];
    self.deleteImg.layer.cornerRadius = Pic_Width_Half;
    self.deleteImg.layer.masksToBounds = YES;
    
    [self.editImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.midBackView.mas_right).with.offset(-130);
        make.centerY.mas_equalTo(self.midBackView.mas_centerY);
        make.height.mas_equalTo(Pic_Width);
        make.width.mas_equalTo(Pic_Width);
    }];
    self.editImg.layer.cornerRadius = Pic_Width_Half;
    self.editImg.layer.masksToBounds = YES;

    [self.translateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.midBackView.mas_centerY);
        make.right.mas_equalTo(self.xxDotButton.mas_left).with.offset(-25);
        make.height.mas_equalTo(self.translateButton.mas_height);
        make.width.mas_equalTo(self.translateButton.mas_width);
    }];
    
    [self.recordBeginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareImg.mas_bottom).with.offset(10);
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.width.mas_equalTo(self.recordBeginLabel);
        make.height.mas_equalTo(self.recordBeginLabel);
    }];
    
    [self.recordTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.xxDotButton.mas_right);
        make.centerY.mas_equalTo(self.recordBeginLabel.mas_centerY);
        make.height.mas_equalTo(self.recordTimeLabel);
        make.width.mas_equalTo(self.recordTimeLabel);
    }];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
        _backView.layer.borderWidth = 1.0;
        _backView.layer.borderColor = c_e0e0e0.CGColor;
    }
    return _backView;
}

- (PaddingLabel *)topCardLabel {
    if (!_topCardLabel) {
        _topCardLabel = [[PaddingLabel alloc] initWithFrame:CGRectZero];
        _topCardLabel.text = @"课堂笔记";
        [_topCardLabel setEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        _topCardLabel.textColor = WhiteColor;
        _topCardLabel.font = [UIFont systemFontOfSize:18];
        _topCardLabel.backgroundColor = [UIColor purpleColor];
    }
    return _topCardLabel;
}

- (UIImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [UIImageView new];
        _arrowImg.image = [UIImage imageNamed:@"record_file_in"];
    }
    return _arrowImg;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.text = @"啊啊啊";
        _nameLabel.numberOfLines = 0;
        _nameLabel.textColor = c_666666;
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)recordBeginLabel {
    if (!_recordBeginLabel) {
        _recordBeginLabel = [UILabel new];
        _recordBeginLabel.text = @"unKnow";
        _recordBeginLabel.textColor = c_666666;
        _recordBeginLabel.font = [UIFont systemFontOfSize:14];
    }
    return _recordBeginLabel;
}

- (UILabel *)recordTimeLabel {
    if (!_recordTimeLabel) {
        _recordTimeLabel = [UILabel new];
        _recordTimeLabel.textColor = c_666666;
        _recordTimeLabel.font = [UIFont systemFontOfSize:14];
        _recordTimeLabel.text = @"12:12:12";
    }
    return _recordTimeLabel;
}

- (UIButton *)translateButton {
    if (!_translateButton) {
        _translateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_translateButton setTitleColor:RedColor forState:UIControlStateNormal];
        [_translateButton setTitle:@"转文字" forState:UIControlStateNormal];
        _translateButton.layer.borderColor = RedColor.CGColor;
        _translateButton.layer.cornerRadius = 2.0;
        _translateButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_translateButton setContentEdgeInsets:UIEdgeInsetsMake(3, 6, 3, 6)];
        _translateButton.layer.borderWidth  = 1.0;
        _translateButton.alpha = 1;
    }
    return _translateButton;
}

- (ClickImageView *)shareImg {
    if (!_shareImg) {
        _shareImg = [[ClickImageView alloc] init];
        _shareImg.contentMode = UIViewContentModeCenter;
        _shareImg.image = [UIImage imageNamed:@"record_file_share"];
        _shareImg.backgroundColor = c_2fc7f7;
        _shareImg.layer.cornerRadius = Pic_Width_Half;
        _shareImg.layer.masksToBounds = YES;
        _shareImg.alpha = 0;
    }
    return _shareImg;
}

- (UIButton *)xxDotButton {
    if (!_xxDotButton) {
        _xxDotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_xxDotButton setBackgroundImage:[UIImage imageNamed:@"recordfile_3dot"] forState:UIControlStateNormal];
        _xxDotButton.contentMode = UIViewContentModeCenter;
        [_xxDotButton setBackgroundImage:[UIImage imageNamed:@"recordfile_xx"] forState:UIControlStateSelected];
        [_xxDotButton addTarget:self action:@selector(clickIt:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _xxDotButton;
}

- (ClickImageView *)editImg {
    if (!_editImg) {
        _editImg = [[ClickImageView alloc] init];
        [_editImg setBackgroundColor:c_FF9A47];
        [_editImg setImage:[UIImage imageNamed:@"record_file_rename"]];
        [_editImg setContentMode:UIViewContentModeCenter];
        _editImg.alpha = 0;
    }
    return _editImg;
}

- (ClickImageView *)deleteImg {
    if (!_deleteImg) {
        _deleteImg = [[ClickImageView alloc] init];
        [_deleteImg setContentMode:UIViewContentModeCenter];
        [_deleteImg setBackgroundColor:RedColor];
        [_deleteImg setImage:[UIImage imageNamed:@"record_file_delete"]];
        _deleteImg.alpha = 0 ;
    }
    return _deleteImg;
}
@end
