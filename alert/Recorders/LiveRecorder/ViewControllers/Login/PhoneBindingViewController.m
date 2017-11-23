//
//  PhoneBindingViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/5.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PhoneBindingViewController.h"
#import "LoginTextField.h"
#import "LoginRequest.h"
#import "AppDelegate.h"
@interface PhoneBindingViewController ()

@property (nonatomic, strong) LoginTextField *mobileTextField;
@property (nonatomic, strong) UIButton *getValidateCodeButton;
@property (nonatomic, strong) LoginTextField *validateCodeTextField;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) NSTimer*  timer;
@property (nonatomic, assign) int seconds;

#define SECOND_MAX_VALUE    60
#define SECOND_MIN_VALUE    1
#define TIME_INTERVAL       1.0

@end

@implementation PhoneBindingViewController

- (instancetype)initWithdAuthType:(NSString *)type withId:(NSString *)theId {
    if (self = [super init]) {
        self.type = type;
        self.theId = theId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self userInteractSetting];
    [self initUI];
}

//点击登录
- (void)tapLoginButton:(UIButton *)button {
    if (self.mobileTextField.text.length < 11 || self.validateCodeTextField.text.length < 6) {
        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请输入有效的手机号或验证码" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
            if (buttonIndex == 0) {
                [dialog hide];
            }
        }] show];
    } else {
        [LoginRequest loginWithMobile:self.mobileTextField.text andSmsCode:self.validateCodeTextField.text AndAuthType:self.type withId:self.theId WithState:^(int a) {
            if (a == HTTP_OK) {
                AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [delegate initRootViewController];
            }
        }];
    }
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

- (void)initUI {
    [self.view addSubview:self.mobileTextField];
    [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(80 * ADJUSTHEIGHT);
        make.left.mas_equalTo(self.view).with.offset(48 * ADJUSTWIDTH);
        make.right.mas_equalTo(self.view.mas_right).with.offset(- 48 * ADJUSTWIDTH);
        make.height.mas_equalTo(40 * ADJUSTHEIGHT);
    }];
    
    [self.view addSubview:self.getValidateCodeButton];
    
    [self.getValidateCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.getValidateCodeButton);
        make.width.mas_equalTo(self.getValidateCodeButton);
        make.right.mas_equalTo(self.mobileTextField.mas_right).with.offset(-5);
        make.bottom.mas_equalTo(self.mobileTextField.mas_bottom).with.offset(-5);
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
        _loginButton.layer.cornerRadius = 10;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _loginButton.layer.masksToBounds = YES;
        [_loginButton setTitle:@"确 定" forState:(UIControlStateNormal)];
        [_loginButton addTarget:self action:@selector(tapLoginButton:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _loginButton;
}
@end
