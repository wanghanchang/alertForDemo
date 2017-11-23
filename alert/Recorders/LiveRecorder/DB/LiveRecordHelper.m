//
//  LiveRecordHelper.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/28.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "LiveRecordHelper.h"

@implementation LiveRecordInSqlite


- (id)entityFromResultSet:(FMResultSet *)resultSet {
    EntityLiveRecord *entity = [EntityLiveRecord new];
    entity.entityId = [resultSet longForColumn:kColID];
    entity.fileLength = [resultSet longForColumn:kFileLength];
    entity.fileId = [resultSet stringForColumn:kfileId];
    entity.isFinishUplaod = [resultSet boolForColumn:kisFinishUplaod];
    entity.isFinishBindOrder = [resultSet boolForColumn:kisFinishBindOrder];
    entity.resultTransStr = [resultSet stringForColumn:kresultTransStr];
    entity.expandName = [resultSet stringForColumn:kExpandName];
    entity.translateState = [resultSet longForColumn:kTranslateState];
    entity.startTime = [resultSet longForColumn:kStartTime];
    entity.timeLong = [resultSet intForColumn:ktimeLong];
    entity.recordTagColor = [resultSet stringForColumn:kRecordTagColor];
    entity.recordTag = [resultSet stringForColumn:kRecordTag];
    entity.fileName = [resultSet stringForColumn:kFileName];
    entity.orderId = [resultSet stringForColumn:kOrderId];
    entity.userNamedFile = [resultSet stringForColumn:kuserNamedFile];
    return entity;
}

- (NSDictionary *)contentValuesFromEntity:(id)entity {
    EntityLiveRecord *record = entity;
    return @{kFileLength : [NSNumber numberWithLong:record.fileLength],
             kfileId : TYPE_TEXT(record.fileId),
             kisFinishUplaod :  [NSNumber numberWithBool:record.isFinishUplaod],
             kisFinishBindOrder : [NSNumber numberWithBool:record.isFinishBindOrder],
             kresultTransStr : TYPE_TEXT(record.resultTransStr),
             kExpandName : TYPE_TEXT(record.expandName),
             kTranslateState : [NSNumber numberWithInteger:record.translateState],
             kStartTime : [NSNumber numberWithLong:record.startTime],
             ktimeLong : [NSNumber numberWithInt:record.timeLong],
             kRecordTagColor : TYPE_TEXT(record.recordTagColor),
             kRecordTag : TYPE_TEXT(record.recordTag),
             kOrderId : TYPE_TEXT(record.orderId),
             kFileName : TYPE_TEXT(record.fileName),
             kuserNamedFile : TYPE_TEXT(record.userNamedFile),
             };
}
@end

@implementation LiveRecordHelper

- (NSArray *)listByRecordState:(TranslateStatus)state {
    SqliteQuery * q = [SqliteQuery queryWithTable:self.tableName forColumns:@[@"*"] whereMatches:@{kTranslateState: [NSNumber numberWithInteger:state]}];
    NSArray *array = [self.helper db_query:q usingWrapper:self.wrapper];
    return array;
}

- (NSArray *)listByRecordTag:(NSString *)Tag {
    SqliteQuery * q = [SqliteQuery queryWithTable:self.tableName forColumns:@[@"*"] whereMatches:@{kRecordTag: TYPE_TEXT(Tag)} withDesc:kStartTime];
    NSArray *array = [self.helper db_query:q usingWrapper:self.wrapper];
    return array;
}

- (NSArray*)listAllDesc {
    NSString *q = @"select * from tableRecord ORDER BY startTime DESC";
    return [self.helper db_query2:q usingWrapper:self.wrapper];
}

- (NSArray*)listByOrderId:(NSString*)orderId {
    SqliteQuery * q = [SqliteQuery queryWithTable:self.tableName forColumns:@[@"*"] whereMatches:@{kOrderId : TYPE_TEXT(orderId)}];
    NSArray *array = [self.helper db_query:q usingWrapper:self.wrapper];
    return array;
}


- (NSArray *)listByNoArrayData:(NSMutableArray *)array {
    NSMutableString *sql1 = [[NSMutableString alloc] initWithString:@"select * from tableRecord where"];
    NSString *seperator = @" AND ";

    for (int i = 2; i <array.count; i++) {
        NSString *str = [NSString stringWithFormat:@" recordTag != %@%@",TYPE_TEXT(array[i]),seperator];
        [sql1 appendString:str];
    }
    NSMutableString *q1 = [NSMutableString stringWithString:[sql1 substringToIndex:sql1
     .length - seperator.length]];
    [q1 appendString:@"ORDER BY startTime DESC"];
    
    NSString *q = [NSString stringWithFormat:@"%@",q1];
    NSArray *arr = [self.helper db_query2:q usingWrapper:self.wrapper];

    return arr;
}


+ (instancetype)helper {
    return [[LiveRecordHelper alloc] initWithDBHelper:[PNCDBHelper sharedHelper]];
}

- (NSString *)tableName {
    return TableRecord;
}

-  (NSString *)primaryKeyColumn {
    return kColID;
}

- (id<EntityInSqlite>)wrapper {
    return [[LiveRecordInSqlite alloc] init];
}

@end

@implementation EntityLiveRecord

@end

