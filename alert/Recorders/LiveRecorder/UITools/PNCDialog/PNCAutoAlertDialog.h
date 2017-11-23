//
//  PNCAutoAlertDialog.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/9/2.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "PNCDialog.h"

@interface PNCAutoAlertView : UIView

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic) PNCDialog *dialog;

@end


@interface PNCAutoAlertDialog : PNCDialog

+ (instancetype)autoAlertWithPic:(NSString*)picName andTitle:(NSString*)titleName;

@end
