//
//  SqliteColumn.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "SqliteColumn.h"

@implementation SqliteColumn

+ (instancetype)columnWithName:(NSString *)name withType:(NSString *)type withConstraint:(NSString *)constraint {
    SqliteColumn *column = [[SqliteColumn alloc] init];
    column.columnName = name;
    column.columnType = type;
    column.columnConstaint = constraint;
    return column;
}



@end
