
//
//  PNCDatePickerDialog.m
//  Project61
//
//  Created by hzpnc on 15/7/22.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "PNCDatePickerDialog.h"
#import "UIColor+Hex.h"
#import "BlocksKit+UIKit.h"

@implementation PNCDatePickerDialog

- (instancetype)init {
    if(self = [super init]) {
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
        self.contentView.backgroundColor = WhiteColor;
        self.contentView.layer.cornerRadius = 5.0f;
        self.contentView.layer.masksToBounds = YES;
        
        self.picker = [[UIDatePicker alloc] init];
        self.picker.datePickerMode = UIDatePickerModeDate;
        self.picker.date = [NSDate date];
        self.picker.timeZone = NSTimeZoneNameStyleStandard;
        
        self.completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        STYLE_BUTTON_1(self.completeButton);
        [self.completeButton setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.picker];
        [self.contentView addSubview:self.completeButton];
        
        [self.completeButton bk_whenTapped:^{
            [self hide];
            self.block(self.picker.date);
        }];
        return self;
    }
    
    return nil;
}

- (void)layoutSubviews {
    
    [self.completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView.mas_width).with.offset(-20);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(-10);
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(10);
    }];
    
    [self.picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView.mas_width);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.completeButton.mas_top).with.offset(20);
    }];
}

+ (void)pickDateWithBlock:(DatePickedBlock) block {
    PNCDatePickerDialog* dialog = [[PNCDatePickerDialog alloc] init];
    dialog.hideWhenTouchUpOutside = YES;
    dialog.block = block;
    [dialog show];
}

@end
