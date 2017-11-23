//
//  MD5Relevant.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/7/26.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "MD5Relevant.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5Relevant

+(NSString *)MD5ForLower32Bate:(NSString *)str{    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}


//登录时密码转md5
+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//字符串转byte数组
+ (Byte *)trunkStringToByte:(NSString *)param length:(int16_t)length {
    Byte *bytes = malloc(sizeof(Byte) * length);
    memset(bytes, 0, length);
    NSString *strings = param;
    NSData *data = [strings dataUsingEncoding:NSUTF8StringEncoding];
    Byte *byte = (Byte*)[data bytes];
    unsigned int i;
    for (i = 0; i < [data length]; i++) {           bytes[i] = byte[i];
    }
    return bytes;
}

//数字转byte数组
+ (Byte *)trunkNumberToByte:(int16_t)param length:(int16_t)length {
    Byte *numByte = malloc(sizeof(Byte) * length);
    memset(numByte, 0, length);
    memcpy(numByte, &param, sizeof(param));
    return numByte;
}

//md5编码转16位byte数组
+ (Byte *)trunkMd5ToByte:(NSString *)param length:(int16_t)length {
    //  NSString * str3=@"ca447808d90c91aebc7445822504d5a8";
    const char *ptr = [param cStringUsingEncoding:NSASCIIStringEncoding];
    Byte *lpByte2 =malloc(sizeof(Byte) * length);
    memset(lpByte2,0,length);
    
    for (int i=0; i<length; i++) {
        int16_t ch1= [MD5Relevant hexCharToInt:ptr[i*2]];
        int16_t ch2= [MD5Relevant hexCharToInt:ptr[i*2+1]];
        int16_t ch3=ch1<<4;
        Byte aa=ch3 |ch2;
        lpByte2[i]=aa;
    }
    return lpByte2;
}

+ (int16_t) hexCharToInt: (char) inChar{
    int16_t ret=(int16_t)inChar;
    if (ret>=48 && ret<=57) {
        ret=ret-48;
    }
    if (ret>=65 && ret<=90) {
        ret=ret-55;
    }
    if (ret>=97 && ret<=122) {
        ret=ret-87;
    }
    return ret;
}

/**
 * 转换16位字节数组为32进制字符串
 */
+ (NSString *)convert16ByteTo32HexStr:(Byte *)paramBuffer{
    Byte* retBuffer2 =malloc(sizeof(Byte) * 16*2);
    
    for (int i=0; i<16; i++) {
        retBuffer2[i*2]=paramBuffer[i]/16;
        retBuffer2[i*2+1]=paramBuffer[i]%16;
    }
    
    char* retChar=malloc(sizeof(char) * 16*2);
    for (int i=0; i<32; i++) {
        if(retBuffer2[i]>=10){
            retChar[i]=65+retBuffer2[i]-10;
        }else{
            retChar[i]=48+retBuffer2[i];
        }
    }
    NSData *adata = [[NSData alloc] initWithBytes:retChar length:32];
    NSString *aString = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
    DLog(@"===%@",aString);    
//    NSString *retStr = [[NSString alloc] initWithCString:retChar encoding:NSUTF8StringEncoding];
    return  aString;
}

#pragma mark-返回md5值

+ (NSString *)return16byteMD5zhaiyao:(NSString*)filePath {
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if( handle== nil ) {
        return nil;
    }
    
    BOOL done = NO;
    NSMutableString *ret=[[NSMutableString alloc] init];
    while(!done)
    {
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        NSData* fileData = [handle readDataOfLength: FILE_BLOCK_SIZE];
        
        DLog(@"fileLenth=%ld",fileData.length);
        
        if ([fileData length]>0) {
            CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5_Final(digest, &md5);
            NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           digest[0], digest[1],
                           digest[2], digest[3],
                           digest[4], digest[5],
                           digest[6], digest[7],
                           digest[8], digest[9],
                           digest[10], digest[11],
                           digest[12], digest[13],
                           digest[14], digest[15]];
            // DLog(@"mid-----md5---%@",s);
            [ret appendString:s];
        }
        if( [fileData length] == 0 ) done = YES;
    }
    NSString* fileMd5= [[MD5Relevant MD5_16byte:[ret uppercaseString]] uppercaseString];
    return fileMd5;
}

+ (NSString *)MD5_16byte:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



@end
