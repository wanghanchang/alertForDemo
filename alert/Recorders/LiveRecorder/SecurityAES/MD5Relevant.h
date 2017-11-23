//
//  MD5Relevant.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/7/26.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILE_BLOCK_SIZE 128*1024

@interface MD5Relevant : NSObject

+ (NSString *)MD5ForLower32Bate:(NSString *)str;

+ (NSString *)md5:(NSString *)str;

+ (NSString *)return16byteMD5zhaiyao:(NSString*)filePath;

+ (Byte *)trunkMd5ToByte:(NSString*)param length:(int16_t)length;

+ (Byte *)trunkNumberToByte:(int16_t)param length:(int16_t)length;

+ (Byte *)trunkStringToByte:(NSString *)param length:(int16_t)length;

+ (NSString *)MD5_16byte:(NSString *)str;

+(NSString *)convert16ByteTo32HexStr:(Byte *)paramBuffer;

@end
