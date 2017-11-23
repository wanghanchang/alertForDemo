//
//  PNCDatePickerDialog.h
//  Project61
//
//  Created by hzpnc on 15/7/22.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "PNCDialog.h"

typedef void(^DatePickedBlock)(NSDate* date);

@interface PNCDatePickerDialog : PNCDialog

@property UIButton*         completeButton;
@property UIDatePicker*     picker;

@property(copy) DatePickedBlock block;

+ (void)pickDateWithBlock:(DatePickedBlock) block;

@end
