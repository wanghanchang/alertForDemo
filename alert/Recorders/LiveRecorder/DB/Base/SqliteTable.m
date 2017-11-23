//
//  SqliteTable.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "SqliteTable.h"
#import "SqliteColumn.h"

@implementation SqliteTable

+ (instancetype)tableWithName:(NSString *)name withColumns:(NSArray *)columms withPrimaryKeyColumn:(NSString *)column {
    SqliteTable *table = [[SqliteTable alloc] init];
    table.tableName = name;
    table.columnsArray = columms;
    table.primaryKeyColumn = column;
    return table;
}

- (NSString*)createTableSql {
    return [NSString stringWithFormat:@"create table if not exists %@ (%@)",self.tableName, [self columsAsSql]];
}

- (NSString*)columsAsSql {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [self.columnsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SqliteColumn *column = obj;
        [sql appendFormat:@"%@ %@ %@,",column.columnName,column.columnType,column.columnConstaint];
    }];
    return [sql substringToIndex:sql.length - 1];
}
@end
