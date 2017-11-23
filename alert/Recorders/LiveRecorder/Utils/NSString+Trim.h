//
//  NSString+Trim.h
//  Project61
//
//  Created by hzpnc on 15/11/27.
//  Copyright © 2015年 hzpnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Trim)

//去除首尾空格
- (NSString*)trim;

- (NSString*)trimHeader;
- (NSString*)trimFooter;

- (NSString*)trimAll;

@end
