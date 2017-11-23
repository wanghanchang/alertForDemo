//
//  TagInfo.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/17.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagInfo : NSObject
@property (nonatomic) int sec ;
@property (nonatomic,copy) NSString *info;
@property (nonatomic) BOOL isNew;
@property (nonatomic) CGRect rectDelete;
@property (nonatomic) CGRect rectNote;

@end
