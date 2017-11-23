//
//  CallRecorderHelper.m
//  PersonalRecord
//
//  Created by hzpnc on 16/7/22.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "CallRecorderHelper.h"

#import <Foundation/Foundation.h>


@implementation EntityCallRecorder

@end

@implementation CallRecorderInSqlite

- (id)entityFromResultSet:(FMResultSet *)resultSet {
    EntityCallRecorder *entity = [EntityCallRecorder new];
    entity.entityId = [resultSet longForColumn:kColID];
    entity.duration = [resultSet stringForColumn:kDuration];
    entity.beginTime = [resultSet stringForColumn:kBegintime];
    entity.direction = [resultSet stringForColumn:kDirection];
    entity.isCollect = [resultSet longForColumn:kIsCollect];
    entity.download = [resultSet stringForColumn:kDownload];
    entity.ext = [resultSet stringForColumn:kExt];
    entity.contactNumber = [resultSet stringForColumn:kContactNumber];
    entity.note = [resultSet stringForColumn:kNote];
    entity.listen = [resultSet stringForColumn:kListen];
    entity.recordId = [resultSet stringForColumn:kRecordid];
    entity.size = [resultSet stringForColumn:KSize];

    return entity;
}

- (NSDictionary *)contentValuesFromEntity:(id)entity {
    EntityCallRecorder *callREcorder = entity;
    return @{
             kColID : [NSNumber numberWithInteger:callREcorder.entityId],
             kDuration : TYPE_TEXT(callREcorder.duration),  
             kBegintime :  TYPE_TEXT(callREcorder.beginTime),
             kDirection : TYPE_TEXT(callREcorder.direction),
             kDownload : TYPE_TEXT(callREcorder.download),
             kIsCollect : [NSNumber numberWithBool:callREcorder.isCollect],
             kContactNumber :  TYPE_TEXT(callREcorder.contactNumber),
             KSize :  TYPE_TEXT(callREcorder.size),
             kExt : TYPE_TEXT(callREcorder.ext),
             kListen : TYPE_TEXT(callREcorder.listen),
             kRecordid : TYPE_TEXT(callREcorder.recordId),
             kNote :  TYPE_TEXT(callREcorder.note)
             };
}

@end

@implementation CallRecorderHelper

+ (instancetype)helper {
    return [[CallRecorderHelper alloc] initWithDBHelper:[PNCDBHelper sharedHelper]];
}

- (NSArray *)listByOrderedDesc {
    NSString *q = @"select * from tableCallRecorder order by beginTime desc";
    NSArray *array = [self.helper db_query2:q usingWrapper:self.wrapper];
    return array;
}

- (NSArray *)listByOrderedAsc {
    NSString *q = @"Select * from tableCallRecorder order by beginTime asc";
    NSArray *array = [self.helper db_query2:q usingWrapper:self.wrapper];
    return array;
}

- (EntityCallRecorder*)getCallRecorderByRecordId:(NSString *)recordId {
    SqliteQuery* q = [SqliteQuery queryWithTable:self.tableName
                                      forColumns:@[@"*"]
                                    whereMatches:@{kRecordid : TYPE_TEXT(recordId)}];
    NSArray* result = [self.helper db_query:q usingWrapper:self.wrapper];
    if(result.count > 0) {
        return result[0];
    }
    return nil;
}

- (BOOL)updateEntityByKey:(NSString *)key value:(NSString *)value forRecordId:(NSString *)recordId {
    SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName
                                    whereMatches:@{kRecordid : TYPE_TEXT(recordId)}];
    EntityCallRecorder *entity = [self getCallRecorderByRecordId:recordId];
    if ([key isEqualToString:@"note"]) {
        entity.note = value;
    }
    if ([key isEqualToString:@"fav"]) {
        entity.isCollect = [value boolValue];
    }
    return [self.helper db_updateEntity:entity withQuery:q usingWrapper:self.wrapper];

}

- (void)deleteCallRecord:(NSString*)recordId {
    SqliteQuery* q = [SqliteQuery queryWithTable:kTableCallRecorder whereMatches:@{kRecordid : TYPE_TEXT(recordId)}];
    [self.helper db_deleteEntityUsingQuery:q];
}

- (NSString *)tableName {
    return kTableCallRecorder;
}

-  (NSString *)primaryKeyColumn {
    return kColID;
}

- (id<EntityInSqlite>)wrapper {
    return [[CallRecorderInSqlite alloc] init];
}

@end
