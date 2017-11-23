//
//  CommonUtils.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+ (BOOL)delteFilehWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName;

+ (NSString *)translateTimeCount:(int)secCount;

+ (NSString *)currentTimeSince1970:(long)timestamp;

+ (NSString *)currentTimeNianYueRiSince1970:(long)timestamp;

+ (NSString *)uuid;

+ (NSString *)randomFileWithDirName:(NSString *)DirName andPrefixName:(NSString *)prefixName withSuffix:(NSString*)sufiixName;

+ (NSString*)splitArray:(NSArray*)array withSeperator:(NSString *)seperator;

+ (NSString*)spliterDictionary:(NSDictionary *)dictionary withSepector:(NSString*)seperator;

+ (NSString*)dateToString:(NSDate*)date;

+ (NSString*)paramertersToString:(NSDictionary*)parameters;

+ (NSString *)generateFilePathWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName isTxt:(BOOL)text;

+ (BOOL)writeJsonDataFromDictionaryByPath:(NSString *)path withDic:(NSMutableDictionary *)dic;

+ (NSDictionary *)getJsonDataToDicByPath:(NSString*)path;

+ (NSString *)currentTimeStr;

+ (NSString *)generateFilePathWithUserFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName;

+ (NSString *)generateKey;

+ (NSString *)currentTimeSince1970WithUpLoadType:(long)timestamp;

+ (NSNumber *) getVersionInt;

+ (BOOL)justifyAliPayInstalled;
+ (BOOL)justifyQQInstalled;
+ (BOOL)justifyWechatInstalled;

int  get_music_height();
@end
