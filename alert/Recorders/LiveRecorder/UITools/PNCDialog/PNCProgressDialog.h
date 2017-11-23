//
//  PNCProgressDialog.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/6/4.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCDialog.h"
#import "PNCDialogView.h"

@class PNCProgressViewAlert;

typedef void(^PNCProgressBlock)(PNCDialog* dialog);


@interface PNCProgressViewAlert : PNCDialogView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,strong) UIView *split;
@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,copy) PNCProgressBlock block;
@property (nonatomic,weak) PNCDialog *dialog;

@end


@interface PNCProgressDialog : PNCDialog

+ (instancetype)progressWithTitle:(NSString *)title
                   andCommitBlock:(PNCProgressBlock)block;
@end
