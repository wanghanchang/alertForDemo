//
//  CommonUtils.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "CommonUtils.h"
#import "MD5Relevant.h"
#import "WXApi.h"
#import "PNCAlertDialog.h"
@implementation CommonUtils

+ (NSString *)translateTimeCount:(int)secCount {
    
    NSString *tmphh = [NSString stringWithFormat:@"%d",secCount/3600];
    if ([tmphh length] == 1)
    {
        tmphh = [NSString stringWithFormat:@"0%@",tmphh];
    }
    NSString *tmpmm = [NSString stringWithFormat:@"%d",(secCount/60)%60];
    if ([tmpmm length] == 1)
    {
        tmpmm = [NSString stringWithFormat:@"0%@",tmpmm];
    }
    NSString *tmpss = [NSString stringWithFormat:@"%d",secCount%60];
    if ([tmpss length] == 1)
    {
        tmpss = [NSString stringWithFormat:@"0%@",tmpss];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
}

+ (NSString *)currentTimeStr {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    return  [formatter stringFromDate:date];
}

+ (NSString *)currentTimeSince1970:(long)timestamp {
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    return  [formatter stringFromDate:confromTimesp];
}

+ (NSString *)currentTimeNianYueRiSince1970:(long)timestamp {
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    return  [formatter stringFromDate:confromTimesp];
}

+ (NSString *)currentTimeSince1970WithUpLoadType:(long)timestamp {
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return  [formatter stringFromDate:confromTimesp];
}

+ (NSString *)uuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

+ (NSString *)randomFileWithDirName:(NSString *)DirName andPrefixName:(NSString *)prefixName withSuffix:(NSString*)sufiixName {
    NSString *fileName = nil;
    if (sufiixName) {
        fileName = [NSString stringWithFormat:@"%@_%@.%@",prefixName,[CommonUtils uuid],sufiixName];
    } else {
        fileName = [NSString stringWithFormat:@"%@_%@",prefixName,[CommonUtils uuid]];
    }
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@",docPath,DirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        return [CommonUtils randomFileWithDirName:DirName andPrefixName:prefixName withSuffix:sufiixName];
    } else {
        return [docPath stringByAppendingString:[NSString stringWithFormat:@"%@/%@",DirName,fileName]];
    }
}

+ (BOOL)delteFilehWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) [0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@/%@",docPath,DirName,fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return  [fileManager removeItemAtPath:dirPath error:NULL];
}

+ (NSString *)generateFilePathWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName isTxt:(BOOL)text {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) [0];

    NSString *dirPath = [NSString stringWithFormat:@"%@/%@/%@",docPath,DirName,fileName];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                           forKey:NSFileProtectionKey];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:attributes error:nil];
        return [CommonUtils generateFilePathWithFileName:fileName andFileManagerName:DirName isTxt:text];
    } else {
        if (text) {
            return [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_info",fileName]];
        } else {
            return [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
        }
    }
}

+ (NSString *)generateFilePathWithUserFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) [0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@",docPath,DirName];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                           forKey:NSFileProtectionKey];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:attributes error:nil];
        return [CommonUtils generateFilePathWithUserFileName:fileName andFileManagerName:DirName];
    } else {
        return [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    }
}


+ (NSString*)splitArray:(NSArray*)array withSeperator:(NSString *)seperator {
    NSMutableString *string = [[NSMutableString alloc] init];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@,",obj];
    }];
    return [string substringToIndex:string.length - 1];
}

+ (NSString*)spliterDictionary:(NSDictionary *)dictionary withSepector:(NSString*)seperator  {
    NSMutableString *string = [[NSMutableString alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@=%@%@",key,obj,seperator];
    }];
    return [string substringToIndex:string
            .length - seperator.length];
}

+ (NSString*)dateToString:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSString*)paramertersToString:(NSDictionary*)parameters {
    NSMutableString *dataString = [[NSMutableString alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [dataString appendFormat:@"%@=%@&",key,obj];
    }];
    return [dataString substringToIndex:dataString.length - 1];
}

+ (BOOL)writeJsonDataFromDictionaryByPath:(NSString *)path withDic:(NSMutableDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return  [jsonData writeToFile:path atomically:YES];
}

+ (NSDictionary *)getJsonDataToDicByPath:(NSString*)path {
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (exist) {
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        return dic;
    }
    return nil;
}

+ (NSString *)generateKey {
    NSString *smsCode = [[AccountInfo shareInfo] systemCode];
    NSString *mobile = [[AccountInfo shareInfo] mobile];
    if (smsCode && mobile) {
        NSString *baseStr = [NSString stringWithFormat:@"shell=PNCLONGLIVE&mobile=%@&smsCode=%@",mobile,smsCode];
        NSString *digest = [MD5Relevant MD5ForLower32Bate:baseStr];
        DLog(@"D=%@",digest);
        NSString *key = [[MD5Relevant MD5ForLower32Bate:[NSString stringWithFormat:@"%@&digest=%@",baseStr,digest]] uppercaseString];
        return key;
    }
    return nil;
}

+ (BOOL)justifyWechatInstalled {
//    if (![WXApi isWXAppInstalled]) {
//        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请先安装微信客户端" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
//            [dialog hide];
//        }] show];
//        return NO;
//    }
    return YES;
}

+ (BOOL)justifyQQInstalled {
//    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqqapi://"]]) {
//        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请先安装QQ客户端" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
//            [dialog hide];
//        }] show];
//        return NO;
//    }
    return YES;

}

+ (BOOL)justifyAliPayInstalled {
//    if (![[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"alipay:"]]) {
//        [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"请先安装支付宝客户端" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
//            [dialog hide];
//        }] show];
//        return NO;
//    }
    return YES;
}

+ (NSNumber *)getVersionInt {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSInteger versionInt = [[version stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    return [NSNumber numberWithInteger:versionInt];
}

int  get_music_height() {
    if (iPhone5) {
        return 270;
    } else if (iPhone6) {
        return 360;
    } else if (iPhone6plus) {
        return 420;
    } else {
        return 180;
    }
}

@end
