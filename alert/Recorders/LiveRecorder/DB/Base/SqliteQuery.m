//
//  SqliteQuery.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "SqliteQuery.h"

@implementation SqliteQuery

+ (SqliteQuery*)queryWithTable:(NSString *)table forColumns:(NSArray *)columns {
    return [SqliteQuery queryWithTable:table forColumns:columns whereMatches:nil];
}

+ (SqliteQuery*)queryWithTable:(NSString *)table forColumns:(NSArray *)columns whereMatches:(NSDictionary *)matches {
    SqliteQuery *q = [[SqliteQuery alloc] init];
    q.table = table;
    q.columns = columns;
    q.match = matches;
    return q;
}

+ (SqliteQuery*)queryWithTable:(NSString *)table forColumns:(NSArray *)columns whereMatches:(NSDictionary *)matches withDesc:(NSString*)desc {
    SqliteQuery *q = [[SqliteQuery alloc] init];
    q.table = table;
    q.columns = columns;
    q.match = matches;
    q.desc = desc;
    return q;
}


+ (SqliteQuery *)queryWithTable:(NSString *)table whereMatches:(NSDictionary *)matches {
    SqliteQuery* q = [[SqliteQuery alloc] init];
    q.table = table;
    q.match = matches;
    if(matches) {
        q.selection = [CommonUtils spliterDictionary:matches withSepector:@" AND "];
    }
    return q;
}

- (NSString *)querySQL {
    NSString *columns = nil;
    NSMutableString *sql = [[NSMutableString alloc] init];
    if (self.columns) {
        columns = [CommonUtils splitArray:self.columns withSeperator:@","];
        [sql appendFormat:@"select %@ from %@",columns,self.table];
    }
    
    NSString *match = nil;
    if (self.match) {
        match = [CommonUtils spliterDictionary:self.match withSepector:@" AND "];
        [sql appendFormat:@" where %@",match];
    }
    
    if (self.selection) {
        [sql appendFormat:@" WHERE %@",self.selection];
    }
    
    if (self.desc) {
        [sql appendFormat:@" order by %@ desc",self.desc];
    }
    
    if (self.limit) {
        [sql appendFormat:@" limit %zd offset %zd",self.limit,self.offset];
    }
    return sql;
}

- (NSString*)deleteSQL {
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"DELETE FROM %@",self.table];
    NSString *match = nil;
    if (self.match) {
        match = [CommonUtils spliterDictionary:self.match withSepector:@" AND "];
        [sql appendFormat:@" WHERE %@",match];
    }
    return sql;
}


@end
