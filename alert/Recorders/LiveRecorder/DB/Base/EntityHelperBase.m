//
//  EntityHelperBase.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "EntityHelperBase.h"

@implementation EntityInSqliteBase

+ (instancetype)instanceWithEntityFromDBBlcok:(EntityFromDB)block {
    return [EntityInSqliteBase instanceWithEntityFromDBBlock:block andContentValuesFromEntityBlcok:nil];
}

+ (instancetype)instanceWithContentValuesFromEntity:(ContentValuesFromEntity)block {
    return [EntityInSqliteBase instanceWithEntityFromDBBlock:nil andContentValuesFromEntityBlcok:block];
}

+ (instancetype)instanceWithEntityFromDBBlock:(EntityFromDB)block1 andContentValuesFromEntityBlcok:(ContentValuesFromEntity)block2 {
    EntityInSqliteBase *base = [[EntityInSqliteBase alloc] init];
    base.entityFromDBBlcok = block1;
    base.ContentValuesFromEntityBlock = block2;
    return base;
}

- (id)entityFromResultSet:(FMResultSet *)resultSet {
    return self.entityFromDBBlcok(resultSet);
}

- (NSDictionary *)contentValuesFromEntity:(id)entity {
    return self.ContentValuesFromEntityBlock(entity);
}

@end

@implementation EntityHelperBase

- (instancetype)initWithDBHelper:(PNCDBHelper *)helper {
    if (self = [super init]) {
        self.helper = helper;
        return self;
    }
    return nil;
}

- (NSString *)tableName {
    return nil;
}

- (NSString *)primaryKeyColumn {
    return  nil;
}

- (id<EntityInSqlite>)wrapper {
    return nil;
}

- (NSArray*)list {
    SqliteQuery* q = [SqliteQuery queryWithTable:self.tableName forColumns:@[@"*"]];
    return [self.helper db_query:q usingWrapper:self.wrapper];
}

- (id)get:(NSInteger)entityId {
    SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName forColumns:@[@"*"] whereMatches:@{kColID :[NSNumber numberWithInteger:entityId]}];
    id entity = [self.helper db_get:q usingWrapper:self.wrapper];
    return entity;
}

- (BOOL)updateEntity:(id)entity forEntityId:(NSInteger)entityId {
    SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName whereMatches:@{kColID : [NSNumber numberWithInteger:entityId]}];
    return [self.helper db_updateEntity:entity withQuery:q usingWrapper:self.wrapper];
}

- (NSInteger)remove:(NSInteger)entityId {
    SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName whereMatches:@{kColID : [NSNumber numberWithInteger:entityId]}];
    return [self.helper db_deleteEntityUsingQuery:q];
}

- (NSInteger)add:(id)entity {
    return [self.helper db_addEntity:entity ToTable:[self tableName] usingWrapper:[self wrapper]];
}

- (NSInteger)addAll:(NSArray *)entities {
    return [self.helper db_addentities:entities toTable:self.tableName usingWrapper:self.wrapper];
}

- (void)clear {
    SqliteQuery *q = [SqliteQuery queryWithTable:self.tableName whereMatches:@{@"1" : @"1"}];
    [self.helper db_deleteEntityUsingQuery:q];
}

@end
