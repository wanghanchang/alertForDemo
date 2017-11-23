//
//  LoginViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/23.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginTextField.h"
#import "IconLoginView.h"

#import "LoginRequest.h"
#import "MD5Relevant.h"
#import "PhoneBindingViewController.h"
#import "AppDelegate.h"
#import "UserNoteViewController.h"


@interface LoginViewController ()<UITextViewDelegate,TencentSessionDelegate,WXApiDelegate>
{
    TencentOAuth *tencentOAuth;
}
@property (nonatomic, strong) UIImageView *ironImg;
@property (nonatomic, strong) LoginTextField *mobileTextField;
@property (nonatomic, strong) UIButton *getValidateCodeButton;
@property (nonatomic, strong) LoginTextField *validateCodeTextField;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIView *rightLineView;
@property (nonatomic, strong) UILabel *thirdLoginLabel;


@property (nonatomic, strong) UIButton *agreeBtn;
@property (nonatomic, strong) UILabel *agreeLabel;
@property (nonatomic, strong) UILabel *agreeLabel2;

@property (nonatomic, strong) NSTimer*  timer;
@property (nonatomic, assign) int seconds;

@property (nonatomic, strong) IconLoginView *QQView;
@property (nonatomic, strong) IconLoginView *WechatView;

@property (nonatomic,strong) UIView *topLine;

#define FORM_INPUT_HEIGHT   44
#define SECOND_MAX_VALUE    60
#define SECOND_MIN_VALUE    1
#define TIME_INTERVAL       1.0

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    [self setTitle:@"登录"];
    [self initUI];
    [self userInteractSetting];
    
    [self.WechatView bk_whenTapped:^{
        if (self.agreeBtn.selected == NO) {
            [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请同意用户协议" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                if (buttonIndex == 0) {
                    [dialog hide];
                }
            }] show];
        } else {
            if (![WXApi isWXAppInstalled]) {
                SendAuthReq *req = [[SendAuthReq alloc] init];
                req.scope = @"snsapi_userinfo";
                req.state = @"App";
                [WXApi sendAuthReq:req viewController:self delegate:self];
            } else {
                if ([WXApi isWXAppInstalled]) {
                    SendAuthReq *req = [[SendAuthReq alloc] init];
                    req.scope = @"snsapi_userinfo";
                    req.state = @"App";
                    [WXApi sendReq:req];
                }
            }
        }
    }];
    
    [self.QQView bk_whenTapped:^{
        if (self.agreeBtn.selected == NO) {
            [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请同意用户协议" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                if (buttonIndex == 0) {
                    [dialog hide];
                }
            }] show];
        } else {
            tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
            NSArray* permissions = [NSArray arrayWithObjects:
                                    kOPEN_PERMISSION_GET_USER_INFO,
                                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                    kOPEN_PERMISSION_GET_INFO,
                                    nil];
            [tencentOAuth setAuthShareType:[self getAuthType]];
            [tencentOAuth authorize:permissions];
        }
    }];
    
    
    self.agreeLabel2.userInteractionEnabled = YES;
    [self.agreeLabel2 bk_whenTapped:^{
        UserNoteViewController *vc = [[UserNoteViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)tencentDidNotNetWork {

}



- (void)getResp:(BaseResp *)resp {
    // 向微信请求授权后,得到响应结果
    WechatQQRequest *request = [[WechatQQRequest alloc] init];
    [request getAuthResult:resp WithStateCode:^(int code) {
        if (code == 0) {
            [request thirdPathDistinguishByType:@"wechat" withId:[[AccountInfo shareInfo] wx_open_id]  WithReturn:^(WechatQQEntity *entity) {
                if (entity.isBind == 0) {
                    PhoneBindingViewController *bind = [[PhoneBindingViewController alloc] initWithdAuthType:@"wechat" withId:[[AccountInfo shareInfo] wx_open_id]];
                    [self.navigationController pushViewController:bind animated:YES];
                } else {
                    //做授权
                    [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:entity.systemCode];
                    [self doAuthWithByType:@"wechat"];
                }
            }];
        }
    }];
}

- (void)doAuthWithByType:(NSString*)type {
    NSString *key =  [CommonUtils generateKey];
    WechatQQRequest *request = [[WechatQQRequest alloc] init];
    [request thirdPathAuthByType:type withMobile:[[AccountInfo shareInfo] mobile] WithKey:key WithReturn:^(int a) {
        if (a == HTTP_OK) {
            [self goMain];
        }
    }];
}

- (void)goMain {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate initRootViewController];
}

//QQ授权登录
- (void)tencentDidLogin
{
    if (tencentOAuth.accessToken.length > 0) {
        [[AccountInfo shareInfo] updateMyProfileWithKey:QQ_TOKEN andValue:tencentOAuth.accessToken];
        [[AccountInfo shareInfo] updateMyProfileWithKey:QQ_OPENID andValue:tencentOAuth.openId];
        [tencentOAuth getUserInfo];
    } else {
        DLog(@"登录不成功 没有获取accesstoken");
    }
}
//非网络错误导致登录失败：
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        DLog(@"用户取消登录");
    } else {
        DLog(@"登录失败");
    }
}

// 获取用户信息
- (void)getUserInfoResponse:(APIResponse *)response {
    
    if (response && response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary *userInfo = [response jsonResponse];
        DLog(@"QQINFO = %@",userInfo);
#warning 未完成 qqInfo xxx
        WechatQQRequest *request = [[WechatQQRequest alloc] init];
                [request thirdPathDistinguishByType:@"qq" withId:[[AccountInfo shareInfo] qq_openId]  WithReturn:^(WechatQQEntity *entity) {
                    if (entity.isBind == 0) {
                        PhoneBindingViewController *bind = [[PhoneBindingViewController alloc] initWithdAuthType:@"qq" withId:[[AccountInfo shareInfo] qq_openId]];
                        [self.navigationController pushViewController:bind animated:YES];
                    } else {
                        //做授权
                        [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:entity.systemCode];
                        [self doAuthWithByType:@"qq"];
                    }
                }];
    } else {
        DLog(@"QQ auth fail ,getUserInfoResponse:%d", response.detailRetCode);
    }
}

- (TencentAuthShareType)getAuthType {
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
    return flag? AuthShareType_TIM :AuthShareType_QQ;
}

- (void)agree:(UIButton*)button {
    button.selected = !button.selected;
}

//点击登录
- (void)tapLoginButton:(UIButton *)button {
    
    if (self.agreeBtn.selected == NO) {
        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请同意用户协议" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
            if (buttonIndex == 0) {
                [dialog hide];
            }
        }] show];
    } else if (self.mobileTextField.text.length < 11 || self.validateCodeTextField.text.length < 6) {
        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请输入有效的手机号或验证码" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
            if (buttonIndex == 0) {
                [dialog hide];
            }
        }] show];
    } else {
        [LoginRequest loginWithMobile:self.mobileTextField.text andSmsCode:self.validateCodeTextField.text WithState:^(int a) {
            if (a == HTTP_OK) {
                [self goMain];
            }
        }];
    }
}

- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return YES;
}

//键盘的位数
- (void)userInteractSetting {
    self.mobileTextField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField *field, NSRange range, NSString *input) {
        char c = [input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if (field.text.length >= 11 && c > 0) {
            return NO;
        }
        return YES;
    };
    
    self.validateCodeTextField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField *field,NSRange range,NSString *input) {
        char c = [input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if (field.text.length >= 6 && c>0) {
            return NO;
        }
        return YES;
    };
}

//验证码
- (void)tapGetValidateCodeButton:(UIButton *)button {
    if (![self valideteEnder]) {
        return;
    }
    [LoginRequest getSmsCodeByPhoneNum:self.mobileTextField.text WithState:^(int a) {
        
    }];
    [self validateCodeCountDown];
}

- (void)validateCodeCountDown {
    _seconds = SECOND_MAX_VALUE;
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)timerFireMethod:(NSTimer *)theTimer {
    if (_seconds == SECOND_MIN_VALUE) {
        [theTimer invalidate];
        _seconds = SECOND_MAX_VALUE;
        [self.getValidateCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.getValidateCodeButton setEnabled:YES];
    } else {
        _seconds--;
        [self.getValidateCodeButton setEnabled:NO];
        [self.getValidateCodeButton setTitleColor:[UIColor colorFromHexString:@"#99CCCCC"] forState:UIControlStateNormal];
        self.getValidateCodeButton.layer.borderColor = [UIColor colorFromHexString:@"#99CCCCC"].CGColor;
        [self.getValidateCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重试", _seconds] forState:UIControlStateDisabled];
    }
}

- (BOOL)valideteEnder {
    if (self.mobileTextField.text.length < 11) {
        [[PNCAlertDialog alertWithTitle:@"提示"
                             andMessage:@"请输入正确的手机号"
                   containsButtonTitles:@[@"好的"]
                   buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                       [dialog hide];
                   }] show];
        return NO;
    }
    return YES;
}

#pragma mark TextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet * cs = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    NSString * filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (basicTest) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = c_e0e0e0;
    }
    return _topLine;
}

- (void)initUI {
    
    [self.view addSubview:self.topLine];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(65);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.view addSubview:self.ironImg];
    
    if (iPhone4) {
        [self.ironImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(self.view.mas_top).with.offset(64 + 40* ADJUSTHEIGHT);
            make.height.mas_equalTo(66);
            make.width.mas_equalTo(66);
        }];
    } else {
        [self.ironImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(self.view.mas_top).with.offset(64 + 40* ADJUSTHEIGHT);
            make.height.mas_equalTo(self.ironImg);
            make.width.mas_equalTo(self.ironImg);
        }];
    }
    
    [self.view addSubview:self.mobileTextField];
    [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.ironImg.mas_bottom).with.offset(60 * ADJUSTHEIGHT);
        make.left.mas_equalTo(self.view).with.offset(48 * ADJUSTWIDTH);
        make.right.mas_equalTo(self.view.mas_right).with.offset(- 48 * ADJUSTWIDTH);
        make.height.mas_equalTo(40 * ADJUSTHEIGHT);
    }];

    [self.view addSubview:self.getValidateCodeButton];
    [self.getValidateCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mobileTextField.mas_bottom).with.offset(-5);
        make.width.mas_equalTo(self.getValidateCodeButton);
        make.right.mas_equalTo(self.mobileTextField.mas_right).with.offset(-5);
        make.height.mas_equalTo(self.getValidateCodeButton);
    }];
    
    [self.view addSubview:self.validateCodeTextField];
    [self.validateCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mobileTextField.mas_bottom).with.offset(10 * ADJUSTHEIGHT);
        make.left.mas_equalTo(self.mobileTextField.mas_left);
        make.right.mas_equalTo(self.mobileTextField.mas_right);
        make.height.mas_equalTo(40 * ADJUSTHEIGHT);
    }];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.validateCodeTextField.mas_bottom).with.offset(30 * ADJUSTHEIGHT);
        make.left.mas_equalTo(self.mobileTextField.mas_left);
        make.right.mas_equalTo(self.mobileTextField.mas_right);
        make.height.mas_equalTo(44 * ADJUSTHEIGHT);
    }];
    
    [self.view addSubview:self.thirdLoginLabel];
    [self.thirdLoginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.loginButton.mas_bottom).with.offset(40 * ADJUSTHEIGHT);
        make.height.mas_equalTo(self.thirdLoginLabel);
        make.width.mas_equalTo(self.thirdLoginLabel);
    }];

    [self.view addSubview:self.leftLineView];
    [self.leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.thirdLoginLabel.mas_centerY);
        make.right.mas_equalTo(self.thirdLoginLabel.mas_left).with.offset(-10);
        make.height.equalTo(@1);
        make.width.mas_equalTo(45 * ADJUSTWIDTH);
    }];
    
    [self.view addSubview:self.rightLineView];
    [self.rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.thirdLoginLabel.mas_centerY);
        make.left.mas_equalTo(self.thirdLoginLabel.mas_right).with.offset(10);
        make.height.equalTo(@1);
        make.width.mas_equalTo(45 * ADJUSTWIDTH);
    }];
    
    [self.view addSubview:self.QQView];
    [self.QQView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.thirdLoginLabel.mas_bottom).with.offset(20* ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.leftLineView.mas_left);
        make.height.mas_equalTo(self.QQView);
        make.width.mas_equalTo(self.QQView);
    }];
    
    [self.view addSubview:self.WechatView];
    [self.WechatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.thirdLoginLabel.mas_bottom).with.offset(20 * ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.rightLineView.mas_right);
        make.height.mas_equalTo(self.WechatView);
        make.width.mas_equalTo(self.WechatView);
    }];
    

    [self.view addSubview:self.agreeLabel];
    [self.agreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-20 * ADJUSTHEIGHT);
        make.centerX.mas_equalTo(self.view.mas_centerX).with.offset(-20);
        make.height.mas_equalTo(self.agreeLabel);
        make.width.mas_equalTo(self.agreeLabel);
    }];
    
    [self.view addSubview:self.agreeLabel2];
    [self.agreeLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.agreeLabel.mas_bottom);
        make.left.mas_equalTo(self.agreeLabel.mas_right);
        make.height.mas_equalTo(self.agreeLabel.mas_height);
        make.width.mas_equalTo(self.agreeLabel2);
    }];
    
    [self.view addSubview:self.agreeBtn];
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.agreeLabel.mas_left).with.offset(-5);
        make.centerY.mas_equalTo(self.agreeLabel.mas_centerY);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(14);
    }];
}

- (UIImageView *)ironImg {
    if (!_ironImg) {
        _ironImg = [[UIImageView alloc] init];
        _ironImg.image = [UIImage imageNamed: @"user_login_iron"];
    }
    return _ironImg;
}

- (LoginTextField *)mobileTextField {
    if (!_mobileTextField) {
        _mobileTextField = [[LoginTextField alloc] init];
        _mobileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName:GrayColor}];
        _mobileTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _mobileTextField.font = [UIFont systemFontOfSize:18];
        _mobileTextField.returnKeyType = UIReturnKeyNext;
        _mobileTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
        _mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
        _mobileTextField.delegate = (id)self;
        _mobileTextField.backgroundColor = WhiteColor;
    }
    return _mobileTextField;
}

- (UIButton *)getValidateCodeButton {
    if (!_getValidateCodeButton) {
        _getValidateCodeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_getValidateCodeButton setTitle:@"验证码" forState:(UIControlStateNormal)];
        _getValidateCodeButton.titleLabel.font = [UIFont systemFontOfSize:14 * ADJUSTWIDTH];
        _getValidateCodeButton.layer.borderColor = RedColor.CGColor;
        _getValidateCodeButton.layer.borderWidth = 1.0;
        [_getValidateCodeButton setContentEdgeInsets:UIEdgeInsetsMake(6, 14, 6, 14)];
        _getValidateCodeButton.layer.cornerRadius = 4;
        _getValidateCodeButton.layer.masksToBounds = YES;
        [_getValidateCodeButton setTitleColor:RedColor forState:(UIControlStateNormal)];
        _getValidateCodeButton.backgroundColor = WhiteColor;
        [_getValidateCodeButton addTarget:self action:@selector(tapGetValidateCodeButton:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _getValidateCodeButton;
}

- (LoginTextField *)validateCodeTextField {
    if (!_validateCodeTextField) {
        _validateCodeTextField = [[LoginTextField alloc] init];
        _validateCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码"attributes:@{NSForegroundColorAttributeName:GrayColor}];
        _validateCodeTextField.backgroundColor = WhiteColor;
        _validateCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _validateCodeTextField.returnKeyType = UIReturnKeyNext;
        _validateCodeTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
        _validateCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _validateCodeTextField.font = [UIFont systemFontOfSize:18];
        _validateCodeTextField.delegate = (id)self;
    }
    return _validateCodeTextField;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_loginButton setTitleColor:WhiteColor forState:(UIControlStateNormal)];
        [_loginButton setBackgroundImage:[UIColor imageFromHexString:@"#fd6a66"] forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 5;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _loginButton.layer.masksToBounds = YES;
        [_loginButton setTitle:@"登  录" forState:(UIControlStateNormal)];
        [_loginButton addTarget:self action:@selector(tapLoginButton:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _loginButton;
}

- (UILabel *)thirdLoginLabel {
    if (!_thirdLoginLabel) {
        _thirdLoginLabel = [[UILabel alloc] init];
        _thirdLoginLabel.text = @"第三方登录";
        _thirdLoginLabel.font = [UIFont systemFontOfSize:12];
        _thirdLoginLabel.textColor = c_666666;
    }
    return _thirdLoginLabel;
}

- (UIView *)leftLineView {
    if (!_leftLineView) {
        _leftLineView = [UIView new];
        _leftLineView.backgroundColor = c_666666;
    }
    return _leftLineView;
}

- (UIView *)rightLineView {
    if (!_rightLineView) {
        _rightLineView = [UIView new];
        _rightLineView.backgroundColor = c_666666;
    }
    return _rightLineView;
}

- (IconLoginView *)QQView {
    if (!_QQView) {
        _QQView = [[IconLoginView alloc] init];
        _QQView.topImg.image = [UIImage imageNamed:@"qq_login_icon"];
        _QQView.userInteractionEnabled = YES;
        _QQView.downLabel.text = @"QQ登录";
    }
    return _QQView;
}

- (IconLoginView *)WechatView {
    if (!_WechatView) {
        _WechatView = [[IconLoginView alloc] init];
        _WechatView.topImg.image = [UIImage imageNamed:@"wechat_login_icon"];
        _WechatView.userInteractionEnabled = YES;
        _WechatView.downLabel.text = @"微信登录";
    }
    return _WechatView;
}

- (UIButton *)agreeBtn {
    if (!_agreeBtn) {
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeBtn.layer.cornerRadius = 7;
        [_agreeBtn addTarget:self action:@selector(agree:) forControlEvents:UIControlEventTouchUpInside];
        [_agreeBtn setImage:[UIImage imageNamed:@"protocal_login"] forState:UIControlStateNormal];
        [_agreeBtn setImage:[UIImage imageNamed:@"protocaled_login"] forState:UIControlStateSelected];
        _agreeBtn.selected = YES;
        }
    return _agreeBtn;
}

- (UILabel *)agreeLabel {
    if (!_agreeLabel) {
        _agreeLabel = [[UILabel alloc] init];
        _agreeLabel.textColor = c_666666;
        NSString *str = @"我已阅读并同意";
        NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],NSKernAttributeName:@0.6f};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
        _agreeLabel.attributedText = attributeStr;
    }
    return _agreeLabel;
}

- (UILabel *)agreeLabel2 {
    if (!_agreeLabel2) {
        _agreeLabel2 = [[UILabel alloc] init];
        _agreeLabel2.textColor = [UIColor redColor];
        NSString *str = @"用户协议";
        NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],NSKernAttributeName:@0.6f,NSUnderlineStyleAttributeName:@1};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
        _agreeLabel2.attributedText = attributeStr;
    }
    return _agreeLabel2;
}
@end
