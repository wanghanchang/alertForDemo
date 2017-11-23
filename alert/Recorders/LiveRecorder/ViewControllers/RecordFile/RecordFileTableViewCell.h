//
//  RecordFileTableViewCell.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/29.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaddingLabel.h"
#import "ClickImageView.h"

@interface RecordFileTableViewCell : UITableViewCell

@property (nonatomic,strong) UIView *backView ;
@property (nonatomic,strong) PaddingLabel *topCardLabel;
@property (nonatomic,strong) UIImageView *arrowImg;
@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *recordBeginLabel;
@property (nonatomic,strong) UILabel *recordTimeLabel;

@property (nonatomic,strong) UIView *midBackView;

@property (nonatomic,strong) ClickImageView *shareImg;
@property (nonatomic,strong) ClickImageView *editImg;
@property (nonatomic,strong) ClickImageView *deleteImg;

@property (nonatomic,strong) UIButton *translateButton;
@property (nonatomic,strong) UIButton *xxDotButton;

@end
