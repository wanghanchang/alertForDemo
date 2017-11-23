//
//  PNCDBHelper.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/28.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteQuery.h"
#import "EntityInSqlite.h"

@interface PNCDBHelper : NSObject

#pragma Properties
@property (nonatomic,copy) NSString* dbPath;

#pragma APIS

+ (instancetype)sharedHelper;

- (BOOL)deleteDB ;

+ (void)switchToDBNamed:(NSString*)dbName;

- (BOOL)isTableExits:(NSString *)tableName;

- (NSInteger)db_addentities:(NSArray*)objects toTable:(NSString*)tableName usingWrapper:(id<EntityInSqlite>) wrapper;

- (NSInteger)db_addEntity:(id)object ToTable:(NSString *)tableName usingWrapper:(id<EntityInSqlite>) wrapper;

- (NSArray*)db_query:(SqliteQuery*)query usingWrapper:(id<EntityInSqlite>)wrapper;

- (id)db_get:(SqliteQuery*)query usingWrapper:(id<EntityInSqlite>)wrapper;

- (NSInteger)db_deleteEntityUsingQuery:(SqliteQuery*) query;

- (BOOL)db_updateEntity:(id)object
              withQuery:(SqliteQuery*)query
           usingWrapper:(id<EntityInSqlite>)wrapper;

- (NSArray*)db_query2:(NSString *)query usingWrapper:(id<EntityInSqlite>)wrapper;

@end