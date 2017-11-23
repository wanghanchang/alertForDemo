//
//  FormValidator.h
//  Project61
//
//  Created by hzpnc on 15/7/9.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITextField;


typedef void(^PrepareTextFieldBlock)(UITextField* field);

typedef NSException*(^ValidateTextFieldBlock)(UITextField* field);


@interface FieldValidator : NSObject

@property NSInteger maxLength;
@property NSInteger minLength;

@property(assign) PrepareTextFieldBlock     prepareBlock;
@property(assign) ValidateTextFieldBlock    validateBlock;

+ (instancetype) validatorWithPrepareBlock:(PrepareTextFieldBlock) prepareBlock
                          andValidateBlock:(ValidateTextFieldBlock) validateBlock;

- (void)prepareTextField:(UITextField*) field;

- (NSException*)validateTextField:(UITextField*) field;

@end

@interface FormValidator : NSObject

@end

@interface NameValidator : FieldValidator
@end

@interface EmailValidator : FieldValidator
@end

@interface PasswordValidator : FieldValidator
@end

@interface ServiceNameValidaor : FieldValidator

@end

