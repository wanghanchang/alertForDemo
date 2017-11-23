//
//  RecordFileEditInfoAlert.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/11.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "RecordFileEditInfoAlert.h"
#import "NSString+Trim.h"

@implementation RecordFileEditInfoAlert

- (CGSize)countScreenSize
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)hide {
    
        CATransform3D currentTransform = self.layer.transform;
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.backgroundColor = [UIColor clearColor];
                             self.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));;
                             self.layer.opacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 [obj removeFromSuperview];
                             }];
                             [self removeFromSuperview];
    
                             [[self.myBackView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 [obj removeFromSuperview];
                             }];
                             [self.myBackView removeFromSuperview];
                         }
         ];
}


- (void)show {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    self.myBackView = [UIView new];
    CGSize screenSize = [self countScreenSize];
    self.myBackView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.myBackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    UIView *frontView = [[window subviews] objectAtIndex:0];
    [frontView addSubview:self.myBackView];
    [frontView addSubview:self];
    
    self.layer.opacity = 0.5f;
    self.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.layer.opacity = 1.0f;
                         self.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}

- (instancetype)initWithFrame:(CGRect)frame WithCancelName:(NSString*)cancelName WithObj:(TagAlertObj *)obj WithBlock:(RecordFileEditInfoAlertBlock)block {
    if (self = [super initWithFrame:frame]) {
        
        self.backView = [UIView new];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.frame = CGRectMake(0 , 0, (SCREENWIDTH - (80* ADJUSTWIDTH)), 200 * ADJUSTHEIGHT);
        [self addSubview:self.backView];
        
        self.backgroundColor = [UIColor clearColor];
        _tagNameLabel = [UILabel new];
        
        _tagNameLabel.font = [UIFont systemFontOfSize:18.0];
        _tagNameLabel.textColor = c_333333;
        _tagNameLabel.text = @"标签名称";
        _tagNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.backView addSubview:self.tagNameLabel];
        [self.tagNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(self.tagNameLabel.mas_width);
            make.height.mas_equalTo(55 * ADJUSTHEIGHT);
        }];
        
        _recordNameLabel = [UILabel new];
        _recordNameLabel.textAlignment = NSTextAlignmentCenter;
        _recordNameLabel.frame= CGRectMake(20 * ADJUSTWIDTH, 55 * ADJUSTHEIGHT, 80 * ADJUSTWIDTH, 30 * ADJUSTHEIGHT);
        _recordNameLabel.layer.borderColor = GrayColor.CGColor;
        _recordNameLabel.layer.borderWidth = 1.0;
        _recordNameLabel.font = [UIFont systemFontOfSize:14.0];
        _recordNameLabel.text = @"录音名称";
        _recordNameLabel.textColor = c_333333;
        [self.backView addSubview:self.recordNameLabel];
        
        _recordNameTextField = [UITextField new];
        _recordNameTextField.frame= CGRectMake(110 * ADJUSTWIDTH, 55 * ADJUSTHEIGHT, 170 * ADJUSTWIDTH, 30 * ADJUSTHEIGHT);
        _recordNameTextField.layer.borderColor = GrayColor.CGColor;
        _recordNameTextField.layer.borderWidth = 1.0;
        _recordNameTextField.font = [UIFont systemFontOfSize:14.0];
        _recordNameTextField.placeholder = @"请输入录音名称";
        UIView *letfView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _recordNameTextField.frame.size.height)];
        _recordNameTextField.leftView = letfView;
        _recordNameTextField.leftViewMode = UITextFieldViewModeAlways;
        [self.backView addSubview:self.recordNameTextField];
        
        
        [_recordNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        _belongLabel = [UILabel new];
        _belongLabel.layer.borderColor = GrayColor.CGColor;
        _belongLabel.layer.borderWidth = 1.0;
        _belongLabel.textAlignment = NSTextAlignmentCenter;
        _belongLabel.frame= CGRectMake(20 * ADJUSTWIDTH, 100 * ADJUSTHEIGHT, 80 * ADJUSTWIDTH, 30 * ADJUSTHEIGHT);
        
        _belongLabel.font = [UIFont systemFontOfSize:14.0];
        _belongLabel.text = @"所属标签";
        _belongLabel.textColor = c_333333;
        [self.backView addSubview:self.belongLabel];
        
        PNCDropdownMenu * dropdownMenu = [[PNCDropdownMenu alloc] init];
        dropdownMenu.frame= CGRectMake(110 * ADJUSTWIDTH, 100 * ADJUSTHEIGHT, 170 * ADJUSTWIDTH, 30 * ADJUSTHEIGHT);
        [self addSubview:dropdownMenu];
        
        NSString *path = [CommonUtils generateFilePathWithUserFileName:COLOR_SETTING andFileManagerName:[[AccountInfo shareInfo] mobile]];
        NSDictionary *dic = [CommonUtils getJsonDataToDicByPath:path];
        NSMutableArray *colorArr;
        if (dic == NULL) {//            默认是#999999 未分组
            self.dateArray = [NSMutableArray arrayWithObject:@"未分组"];
            colorArr = [NSMutableArray arrayWithObject:@"#999999"];
        } else {
            self.dateArray = [NSMutableArray arrayWithArray:[dic allKeys]];
            colorArr = [NSMutableArray arrayWithArray:[dic allValues]];
            [self.dateArray insertObject:@"未分组" atIndex:0];
            [colorArr insertObject:@"#999999" atIndex:0];
        }
        [dropdownMenu setMenuTitles:self.dateArray titleColors:colorArr rowHeight:30];
        dropdownMenu.type = Type_alert;
        dropdownMenu.delegate = self;
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        if ([cancelName isEqualToString:@"删除"]) {
            button.frame= CGRectMake(100 * ADJUSTWIDTH, 150 * ADJUSTHEIGHT, 100 * ADJUSTWIDTH, 35 * ADJUSTHEIGHT);
        } else {
            button.frame= CGRectMake(20 * ADJUSTWIDTH, 150 * ADJUSTHEIGHT, 100 * ADJUSTWIDTH, 35 * ADJUSTHEIGHT);
        }
        [button setBackgroundImage:[UIColor imageFromHexString:@"#fd6a66"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorFromHexString:@"#ffffff"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorFromHexString:@"#ffffff"] forState:UIControlStateNormal];
        [button.titleLabel setFont: [button.titleLabel.font fontWithSize:17]];
        [button setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.backView addSubview:button];
        
        [button bk_whenTapped:^{
            TagAlertObj *obj = [[TagAlertObj alloc] init];
            obj.recordName = _recordNameTextField.text;
            obj.tagName = self.dateArray[_arrayIndex];
            obj.tagColor = colorArr[_arrayIndex];
            DLog(@"%@ = %@",obj.tagColor,obj.recordName);            
            block(self,1,obj);
        }];
    
        if ([cancelName isEqualToString:@"删除"]) {
        } else {
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button2 setTitle:@"取消" forState:UIControlStateNormal];
            button2.frame= CGRectMake(180 * ADJUSTWIDTH, 150 * ADJUSTHEIGHT, 100 * ADJUSTWIDTH, 35 * ADJUSTHEIGHT);
            button2.layer.borderColor = GrayColor.CGColor;
            button2.layer.borderWidth = 1.0;
            [button2 setTitleColor:GrayColor forState:UIControlStateNormal];
            [button2.titleLabel setFont: [button2.titleLabel.font fontWithSize:17]];
            [button2 setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [self.backView addSubview:button2];
            [button2 bk_whenTapped:^{
                block(self,0,nil);
            }];
        }
        
        
        if (obj != nil) {
            self.recordNameTextField.text = obj.recordName;
            [dropdownMenu.mainBtn setBackgroundColor:[UIColor colorFromHexString:obj.tagColor]];
            [dropdownMenu.mainBtn setTitle:obj.tagName forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _recordNameTextField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
}



#pragma mark - PNCDropdownMenu Delegate

- (void)dropdownMenu:(PNCDropdownMenu *)menu selectedCellNumber:(NSInteger)number{
    DLog(@"你选择了：%ld",number);
    _arrayIndex = number;
}

- (void)dropdownMenuWillShow:(PNCDropdownMenu *)menu{
    DLog(@"--将要显示--");
}

- (void)dropdownMenuDidShow:(PNCDropdownMenu *)menu{
    DLog(@"--已经显示--");
}

- (void)dropdownMenuWillHidden:(PNCDropdownMenu *)menu{
    DLog(@"--将要隐藏--");
}
- (void)dropdownMenuDidHidden:(PNCDropdownMenu *)menu{
    DLog(@"--已经隐藏--");
}

@end

@implementation TagAlertObj

@end
