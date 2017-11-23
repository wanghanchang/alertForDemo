//
//  MessageHelper.m
//  PersonalRecord
//
//  Created by hzpnc on 16/8/24.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "MessageHelper.h"

@implementation MessageEntity

@end

@implementation MessageInSqlite

- (id)entityFromResultSet:(FMResultSet *)resultSet {
    MessageEntity *entity = [MessageEntity new];
    entity.entityId = [resultSet longForColumn:kColID];
    entity.messageTime = [resultSet stringForColumn:kMessageTime];
    entity.isNew = [resultSet boolForColumn:kMessageIsNew];
    entity.messageContent = [resultSet stringForColumn:kMessageContent];
    return entity;
}

- (NSDictionary *)contentValuesFromEntity:(id)entity {
    MessageEntity *message = entity;
    return @{kMessageTime : TYPE_TEXT(message.messageTime),
             kColID : [NSNumber numberWithInteger:message.entityId],
             kMessageIsNew : [NSNumber numberWithBool:message.isNew],
             kMessageContent : TYPE_TEXT(message.messageContent)
             };
}

@end

@implementation MessageHelper

- (NSArray *)listByOrderedDesc {
    NSString *q = @"select * from message order by messageTime desc";
    NSArray *array = [self.helper db_query2:q usingWrapper:self.wrapper];
    return array;
}

- (void)updateEntity {
    for (MessageEntity *entity in  [self listByOrderedDesc]) {
        if (entity.isNew) {
            entity.isNew = NO;
            SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName whereMatches:@{kColID : [NSNumber numberWithInteger:entity.entityId]}];
            [self.helper db_updateEntity:entity withQuery:q usingWrapper:self.wrapper];
        }
    }
}


+ (instancetype)helper {
    return [[MessageHelper alloc] initWithDBHelper:[PNCDBHelper sharedHelper]];
}

- (NSString *)tableName {
    return kMessage;
}

-  (NSString *)primaryKeyColumn {
    return kColID;
}

- (id<EntityInSqlite>)wrapper {
    return [[MessageInSqlite alloc] init];
}


@end

