//
//  AES.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/3.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES : NSObject

+ (NSString *)AES128Encrypt:(NSString *)plainText withKey:(NSString *)key;
+(NSString *)AES128Decrypt:(NSString *)encryptText withKey:(NSString *)key;



+(NSString *)AES128Encrypt:(NSString *)plainText withKey:(NSString*)gkey andIV:(NSString*)gIv;
+(NSString *)AES128Decrypt:(NSString *)encryptText withKey:(NSString*)gkey andIV:(NSString*)gIv;
@end
