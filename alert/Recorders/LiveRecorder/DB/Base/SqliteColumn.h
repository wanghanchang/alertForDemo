//
//  SqliteColumn.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteColumn : NSObject

+ (instancetype)columnWithName:(NSString*)name
                      withType:(NSString*)type
                withConstraint:(NSString*)constraint;

@property (nonatomic,copy) NSString * columnName;
@property (nonatomic,copy) NSString * columnType;
@property (nonatomic,copy) NSString * columnConstaint;

@end


