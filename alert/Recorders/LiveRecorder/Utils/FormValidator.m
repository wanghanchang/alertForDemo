//
//  FormValidator.m
//  Project61
//
//  Created by hzpnc on 15/7/9.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "FormValidator.h"
#import <UIKit/UIKit.h>
#import "BlocksKit+UIKit.h"

#define PNC_NAME_MAX            7
#define Space      32


@implementation FieldValidator

+ (instancetype)newInstance {
    return [[FieldValidator alloc] init];
}

+ (instancetype)validatorWithPrepareBlock:(PrepareTextFieldBlock)prepareBlock
                         andValidateBlock:(ValidateTextFieldBlock)validateBlock {
    
    FieldValidator* validator = [[FieldValidator alloc] init];
    validator.prepareBlock = prepareBlock;
    validator.validateBlock = validateBlock;
    return validator;
}

- (void)prepareTextField:(UITextField *)field {
    self.prepareBlock(field);
}

- (NSException*)validateTextField:(UITextField *)field{
    return self.validateBlock(field);
}
@end

@implementation FormValidator

+ (FieldValidator*)validatorForField:(NSString*) fieldName {
    return nil;
}

@end

#pragma Validators By Field

@implementation NameValidator

- (void)prepareTextField:(UITextField *)field {
    field.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField* field, NSRange range, NSString* input) {
        char c =[input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if(c >= 32 && c <= 64) {
            return NO;
        }
        if(c >= 91 && c <= 96) {
            return NO;
        }
        if(c >= 123 && c <= 126) {
            return NO;
        }
        if(c == 0) {
            return YES;
        }
//        if(self.maxLength && field.text.length >= self.maxLength) {
//            return NO;
//        }
        return YES;
    };
}

- (NSException*)validateTextField:(UITextField *)field {
    
    self.maxLength = PNC_NAME_MAX;
    
    if(field.text.length == 0) {
        return [NSException exceptionWithName:@"" reason:@"姓名不能为空" userInfo:nil];
    }
    if(self.maxLength && field.text.length > self.maxLength) {
        return [NSException exceptionWithName:@""
                                       reason:[NSString stringWithFormat:@"姓名太长，请控制在%@个汉字以内",
                                               INTEGER(self.maxLength)] userInfo:nil];
    }
  
    NSString * string = @"^[\u4E00-\u9FA5a-zA-Z]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",string];
    
    if (![numberPre evaluateWithObject:field.text]) {
        return [NSException exceptionWithName:@"" reason:@"请输入中文或者英文" userInfo:nil];
    }
    return nil;
}

@end

@implementation ServiceNameValidaor

- (void)prepareTextField:(UITextField *)field {
    field.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField* field, NSRange range, NSString* input) {
        char c =[input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if(c >= Space && c <= '/') {
            return NO;
        }
        if(c >= ':' && c <= '@') {
            return NO;
        }
        if(c >= '[' && c <= '`') {
            return NO;
        }
        if(c >= '{' && c <= '~') {
            return NO;
        }
        if(c == 0) {
            return YES;
        }
        if(self.maxLength && field.text.length >= self.maxLength) {
            return NO;
        }
        return YES;
    };
}

- (NSException*)validateTextField:(UITextField *)field {
    if(field.text.length == 0) {
        return [NSException exceptionWithName:@"" reason:@"服务名称不能为空" userInfo:nil];
    }
    if(field.text.length > self.maxLength) {
        return [NSException exceptionWithName:@"" reason:[NSString stringWithFormat:@"服务名称不能超过%@位", INTEGER(self.maxLength)]
                                                userInfo:nil];
    }
    
    return nil;
}

@end

@implementation EmailValidator

- (void)prepareTextField:(UITextField *)field {
    field.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField* field, NSRange range, NSString* input) {
        char c =[input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if(c == Space) {
            return NO;
        }
        return YES;
    };
}

- (NSException*)validateTextField:(UITextField *)field {
    
    if(field.text.length == 0) {
        return [NSException exceptionWithName:@"" reason:NSLocalizedString(@"Email must not be empty", nil) userInfo:nil];
    }
    
    if(![self isValidateEmail:field.text]) {
        return [NSException exceptionWithName:@"" reason:NSLocalizedString(@"Invalid email", nil) userInfo:nil];
    }
    
    return nil;
}

-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end

@implementation PasswordValidator

- (void)prepareTextField:(UITextField *)field {
    
    static char chars[70] = "0123456789!@#$%^*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    field.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField* field, NSRange range, NSString* input) {
        char c =[input cStringUsingEncoding:NSUTF8StringEncoding][0];
        if(c == 0) {
            return YES;
        }
        if(field.text.length >= self.maxLength) {
            return NO;
        }
        for(int i = 0; i < 70; i++) {
            if(chars[i] == c) {
                return YES;
            }
        }
        return NO;
    };
}

- (NSException*)validateTextField:(UITextField *)field {
    
    if(field.text.length == 0) {
        return [NSException exceptionWithName:@"" reason:@"Email must not be empty" userInfo:nil];
    }

    return nil;
}

@end
