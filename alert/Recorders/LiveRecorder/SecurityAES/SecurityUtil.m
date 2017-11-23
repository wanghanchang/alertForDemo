//
//  SecurityUtil.h
//  Smile
//
//  Created by 蒲晓涛 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "SecurityUtil.h"
#import "GTMBase64.h"
#import "NSData+AES.h"


@implementation SecurityUtil

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]; 
	return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]; 
	return base64String;
} 

+ (NSString*)encodeBase64Data:(NSData *)data {
	data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
	data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return base64String;
}

#pragma mark - AES加密
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string app_key:(NSString*)key
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key];
    
   NSString *str = [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSLog(@"加密后的字符串 :%@",str);
    return str;
}
//将string转成带密码的data
+(NSData*)encryptAESData1:(NSData*)data_ app_key:(NSString*)key
{
    //将nsstring转化为nsdata
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data_ AES128EncryptWithKey:key];
    
    NSData *data = [encryptedData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"加密后的字符串 :%@",data);
    return data;
}

//将string转成带密码的data
+(NSString*)encryptAESData2:(NSString*)string app_key:(NSString*)key
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key];
    
    NSString *str = [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return str;
}


//将带密码的data转成string
+(NSData*)encryptAESData3:(NSData*)data  app_key:(const void *)key;
{
    //使用密码对data进行解密
    NSData *encryptData = [data AES128EncryptWithKey3:key];
    return encryptData;
}
//将带密码的data转成string II
+(NSString*)encryptAESData4:(NSData *)data app_key:(const void *)key {
    //使用密码对data进行解密
    NSString *encryptByte = [data AES128EncryptWithKey4:key];
    
    return encryptByte;
}



#pragma mark - AES解密
//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data  app_key:(NSString*)key
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey:key];
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSASCIIStringEncoding];
    return [str autorelease];
}

#pragma mark - AES解密
//将带密码的data转成string
+(NSData*)decryptAESData2:(NSData*)data  app_key:(NSString*)key
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey2:key];
    return decryData;
}
#pragma mark - AES解密
//将带密码的data转成string
+(NSData*)decryptAESData3:(NSData*)data  app_key:(const void *)key;
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey3:key];
    return decryData;
}

//将带密码的data转成string
+(NSString*)decryptAESData4:(NSData*)data  app_key:(const void *)key
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey3:key];
    NSLog(@"decryData:%@",decryData);
    Byte *buffer =malloc(sizeof(Byte) * 16);
    [decryData getBytes:buffer length:16];
    
    for (int i=0; i<16; i++) {
        NSLog(@"%d",buffer[i]);
    }
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSASCIIStringEncoding];
    return [str autorelease];
}
@end
