//
//  CommonConfig.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#ifndef CommonConfig_h
#define CommonConfig_h

# define DLog(fmt, ...) NSLog((@"%s [Line %d]" fmt),__PRETTY_FUNCTION__, __LINE__,##__VA_ARGS__)

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define ADJUSTWIDTH [[UIScreen mainScreen]bounds].size.width / 375
#define ADJUSTHEIGHT [[UIScreen mainScreen]bounds].size.height / 667

#define NOT_NULL(val)   ((val) == [NSNull null] || !val) ? @"" : (val)
#define MOBILE      @"mobile"
#define UID         @"uid"
#define SESSEION    @"sid"

#define COLOR_SETTING @"color_setting"

#define WX_ACCESS_TOKEN @"access_token"
#define WX_OPEN_ID  @"openid"
#define WX_REFRESH_TOKEN @"refresh_token"
#define SYSTEM_CODE @"systemCode"
#define QQ_TOKEN @"qq_token"
#define QQ_OPENID @"qq_openId"

#define MainColor [UIColor colorFromHexString:@"#cccccc"]
#define RedColor    [UIColor colorFromHexString:@"#fd6a66"]
#define GrayColor   [UIColor colorFromHexString:@"#999999"]
#define WhiteColor  [UIColor colorFromHexString:@"#FFFFFF"]
#define c_666666    [UIColor colorFromHexString:@"#666666"]
#define c_FF9A47    [UIColor colorFromHexString:@"#ff9a47"]
#define c_333333    [UIColor colorFromHexString:@"#333333"]
#define c_2fc7f7    [UIColor colorFromHexString:@"#2fc7f7"]
#define c_e0e0e0    [UIColor colorFromHexString:@"#e0e0e0"]
#define c_fc5790    [UIColor colorFromHexString:@"#fc5790"]
#define c_999999    [UIColor colorFromHexString:@"#999999"]
#define c_3ab334    [UIColor colorFromHexString:@"#3ab334"]
#define c_f2f2f2    [UIColor colorFromHexString:@"#f2f2f2"]
#define c_eeeeee    [UIColor colorFromHexString:@"#eeeeee"]
#define c_fc524c    [UIColor colorFromHexString:@"#fc524c"]
#define c_cccccc    [UIColor colorFromHexString:@"#cccccc"]
#define c_fd3a32    [UIColor colorFromHexString:@"#fd3a32"]
#define c_ffe6e5    [UIColor colorFromHexString:@"#ffe6e5"]
#define c_d5d5d5    [UIColor colorFromHexString:@"#ffe6e5"]
#define c_888888    [UIColor colorFromHexString:@"#888888"]
#define c_dddddd    [UIColor colorFromHexString:@"#dddddd"]
#define c_777777    [UIColor colorFromHexString:@"#777777"]
#define c_fc3932    [UIColor colorFromHexString:@"#fc3932"]
#define c_3f88db    [UIColor colorFromHexString:@"#3f88db"]
#define c_000000    [UIColor colorFromHexString:@"#000000"]
#define c_E6E6E6    [UIColor colorFromHexString:@"#E6E6E6"]
#define c_F1F1F1    [UIColor colorFromHexString:@"#F1F1F1"]




#define COLOR_0   @"#cccccc"
#define COLOR_1   @"#fc4c8a"
#define COLOR_2   @"#2fc7f7"
#define COLOR_3   @"#ff9a47"
#define COLOR_4   @"#28e272"


#define SUCCESS_PAY  @"success_pay"
#define FAIL_PAY     @"fail_pay"

#define NEWUNDEFINEDRECORD @"new_undefined_record"  


#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480.0)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

#define INTEGER(integer)    [NSNumber numberWithInteger: integer]

#define FONT_LIGHT(float) [UIFont systemFontOfSize:float weight:UIFontWeightLight]
#define FONT_MEDIUM(float) [UIFont systemFontOfSize:float weight:UIFontWeightRegular]
#define FONT_BOLD(float) [UIFont systemFontOfSize:float weight:UIFontWeightMedium]

#define STYLE_BUTTON_7(button) \
[button.titleLabel setFont: [button.titleLabel.font fontWithSize:14]];\
[button setTitleColor:WhiteColor forState:UIControlStateNormal];\
[button setBackgroundImage:[UIColor imageFromHexString:@"#47a8ef"] forState:UIControlStateNormal];\
[button setBackgroundImage:[UIColor imageFromHexString:@"#3883cf"] forState:UIControlStateHighlighted];\
[button setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];\
[button.layer setCornerRadius:5.0f];\
[button.layer setMasksToBounds:YES];


#define STYLE_BUTTON_1(button) \
[button.titleLabel setFont: [button.titleLabel.font fontWithSize:17]];\
[button setTitleColor:[UIColor colorFromHexString:@"#2f74bb"] forState:UIControlStateNormal];\
[button setTitleColor:[UIColor colorFromHexString:@"#7b9bc6"] forState:UIControlStateDisabled];\
[button setTitleColor:[UIColor colorFromHexString:@"#ffffff"] forState:UIControlStateHighlighted];\
[button setBackgroundImage:[UIColor imageFromHexString:@"#eeeeee"] forState:UIControlStateNormal];\
[button setBackgroundImage:[UIColor imageFromHexString:@"#2f74bb"] forState:UIControlStateHighlighted];\
[button setBackgroundImage:[UIColor imageFromHexString:@"#cccccc"] forState:UIControlStateDisabled];\
[button setContentEdgeInsets:UIEdgeInsetsMake(10, 30, 10, 30)];\
[button.layer setBorderColor:[UIColor colorFromHexString:@"#2f74bb"].CGColor];\
[button.layer setBorderWidth:1];\
[button.layer setCornerRadius:9.0f];\
[button.layer setMasksToBounds:YES];

#endif /* CommonConfig_h */
