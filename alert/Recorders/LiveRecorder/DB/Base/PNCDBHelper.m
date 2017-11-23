//
//  PNCDBHelper.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/28.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "PNCDBHelper.h"
#import <FMDB.h>
#import "SqliteTable.h"
#import "Tables.h"

#define DB_VERSION      3

static NSString* dbNameCurrentUsed = nil;
static PNCDBHelper* dbHelper = nil;

@implementation PNCDBHelper

@synthesize dbPath = _dbPath;

+ (void)switchToDBNamed:(NSString *)dbName {
    @synchronized (self) {
        dbNameCurrentUsed = dbName;
        dbHelper = [[PNCDBHelper alloc] initWithDBName:dbNameCurrentUsed];
    }
}

+ (instancetype)sharedHelper {
    return dbHelper;
}

- (instancetype)initWithDBName:(NSString*)DBName {
    @synchronized (self) {
        if (self = [super init]) {
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            self.dbPath = [documentPath stringByAppendingPathComponent:DBName];
            BOOL isDBPathExsit = [[NSFileManager defaultManager] fileExistsAtPath:DBName];
            if (!isDBPathExsit) {
                [self db_shouldCreatedAtPath:_dbPath];
//               assert([self getCurrentDBVersion] == DB_VERSION);
            } else {
//                NSInteger currentDBVersion = [self getCurrentDBVersion];
//                if (currentDBVersion < DB_VERSION) {
//                    [self db_shouldUpgradeFromVersion:currentDBVersion toNewVersion:DB_VERSION withOpenedDB:[self openDatabase]];
//                }
            }
            return self;
        }
        return nil;
    }
}

//- (void)db_shouldUpgradeFromVersion:(NSInteger)oldVersion toNewVersion:(NSInteger)newVersion withOpenedDB:(FMDatabase*)db {
//    @synchronized (self) {
//        <#statements#>
//    }
//}

- (void)db_shouldCreatedAtPath:(NSString*)dbPath {
    @synchronized (self) {
        FMDatabaseQueue *quene = [[FMDatabaseQueue alloc] initWithPath:dbPath];
        [quene inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                [self createTable:[Tables tableRecord] inDatabase:db];
                [self createTable:[Tables callRecorder] inDatabase:db];
                [self createTable:[Tables message] inDatabase:db];
            } @catch (NSException *exception) {
                *rollback = YES;
                DLog(@"DB create Error: %@",exception.reason);
                [self deleteDB];
            }
        }];
    }
}

- (void)createTable:(SqliteTable*)table inDatabase:(FMDatabase*)db {
    @synchronized (self) {
        if (![db executeUpdate:[table createTableSql]]) {
            @throw [NSException exceptionWithName:@"" reason:[NSString stringWithFormat:@"create Table failed %@",table.tableName] userInfo:nil];
        }
    }
}

- (BOOL)deleteDB {
    @synchronized (self) {
        NSError *err;
     return [[NSFileManager defaultManager] removeItemAtPath:_dbPath error:&err];
    }
}

#pragma mark -- public api

- (NSInteger)db_addentities:(NSArray *)objects toTable:(NSString *)tableName usingWrapper:(id<EntityInSqlite>)wrapper {
    @synchronized (self) {
        return [self intergerResultFromOpenedDB:^NSInteger(FMDatabase *db) {
            __block NSInteger count = 0;
            [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *sql = [self insertSqlForObeject:objects wrapper:wrapper inTable:tableName];
                BOOL ok = [db executeUpdate:sql];
                assert(ok);
                count++;
            }];
            return count;
        }];
    }
}

- (NSString *)insertSqlForObeject:(id)object wrapper:(id)wrapper inTable:(NSString*)tableName {
    @synchronized (self) {
        NSDictionary *contentValues = [wrapper contentValuesFromEntity:object];
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        NSMutableArray *vals = [[NSMutableArray alloc] init];
        [contentValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [keys addObject:key];
            [vals addObject:obj];
        }];
        NSString *colAsString = [CommonUtils splitArray:keys withSeperator:@","];
        NSString *valAsString = [CommonUtils splitArray:vals withSeperator:@","];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableName,colAsString,valAsString];
        return sql;
    }
}

- (NSInteger)db_addEntity:(id)object ToTable:(NSString *)tableName usingWrapper:(id<EntityInSqlite>) wrapper {
    return [self intergerResultFromOpenedDB:^NSInteger(FMDatabase *db) {
        NSString *sql = [self insertSqlForObeject:object wrapper:wrapper inTable:tableName];
        DLog(@"%@",sql);
        BOOL ok = [db executeUpdate:sql];
        
        if (ok) {
            SqliteQuery *q = [SqliteQuery queryWithTable:@"sqlite_sequence" forColumns:@[@"seq"] whereMatches:@{@"name" : [NSString stringWithFormat:@"'%@'",tableName]}];
            DLog(@"%@",[q querySQL]);
            FMResultSet *result =[db executeQuery:[q querySQL]];
            if (result.next) {
                return [result longForColumn:@"seq"];
            }
        }
        return 0;
    }];
}


- (NSArray*)db_query2:(NSString *)query usingWrapper:(id<EntityInSqlite>)wrapper {
    @synchronized (self) {
        return [self arrayResultFromOpenDB:^NSArray *(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:query];
            NSMutableArray *array = [[NSMutableArray alloc]
                                     init];
            while (result.next) {
                id entity = [wrapper entityFromResultSet:result];
                [array addObject:entity];
            }
            [result close];
            return array;
        }];
    }
}

- (NSArray*)db_query:(SqliteQuery *)query usingWrapper:(id<EntityInSqlite>)wrapper {
    @synchronized (self) {
        return [self arrayResultFromOpenDB:^NSArray *(FMDatabase *db) {
            DLog(@"%@",[query querySQL]);
            FMResultSet *result = [db executeQuery:[query querySQL]];
            NSMutableArray *array = [[NSMutableArray alloc]
                                     init];
            while (result.next) {
                id entity = [wrapper entityFromResultSet:result];
                [array addObject:entity];
            }
            [result close];
            return array;
            }];
    }
}

- (id)db_get:(SqliteQuery *)query usingWrapper:(id<EntityInSqlite>)wrapper {
    query.limit = 1;
    query.offset = 0;
    NSArray *array = [self db_query:query usingWrapper:wrapper];
    if (array && array.count) {
        return array[0];
    }
    return nil;
}

- (NSInteger)db_deleteEntityUsingQuery:(SqliteQuery *)query {

    @synchronized (self) {
        return [self intergerResultFromOpenedDB:^NSInteger(FMDatabase *db) {
            DLog(@"Delete Sql = %@",[query deleteSQL]);
            return [db executeUpdate:[query deleteSQL]] ? 1 : 0;
        }];
    }
}

- (BOOL)db_updateEntity:(id)object withQuery:(SqliteQuery *)query usingWrapper:(id<EntityInSqlite>)wrapper {
    return [self db_updateTable:query.table withNewContent:[wrapper contentValuesFromEntity:object] bySelection:query.selection];
}

- (BOOL)db_updateTable:(NSString*)table withNewContent:(NSDictionary*)contentValues bySelection:(NSString*)selection {
    @synchronized (self) {
        NSString *cotentsSql = [CommonUtils spliterDictionary:contentValues withSepector:@","];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",table,cotentsSql, !selection ? @"1 = 1": selection];
        return [self boolenResultFromOpenDB:^BOOL(FMDatabase *db) {
            return [db executeUpdate:sql];
        }];
    }

}

- (NSInteger)intergerResultFromOpenedDB:(NSInteger(^)(FMDatabase *db))block {
    FMDatabase *db = [self openDatabase];
    NSInteger result = block(db);
    [self closeDB:db];
    return result;
}

- (BOOL)boolenResultFromOpenDB:(BOOL(^)(FMDatabase *db)) block {
    FMDatabase *db = [self openDatabase];
    BOOL ok = block(db);
    [self closeDB:db];
    return ok;
}


- (NSArray*)arrayResultFromOpenDB:(NSArray*(^)(FMDatabase *db)) block {
    FMDatabase *db = [self openDatabase];
    NSArray *result = block(db);
    [self closeDB:db];
    return result;
}

- (void)closeDB:(FMDatabase*)db {
    @synchronized (self) {
        BOOL ok = [db close];
        if(!ok) {
            @throw [NSException exceptionWithName:@"DBException" reason:@"can not close DB" userInfo:nil];
        }
    }
}

- (BOOL)isTableExits:(NSString *)tableName {
    @synchronized (self) {
        return [self boolenResultFromOpenDB:^BOOL(FMDatabase *db) {
            
            NSString *sql = [NSString stringWithFormat:
                             @"select name from sqlite_master where type='table' and name = '%@'",tableName];
            FMResultSet *resultSet = [db executeQuery:sql];
            return [resultSet next] && [[resultSet stringForColumn:@"name"] isEqualToString:tableName];
        }];
    }
}

- (FMDatabase*)openDatabase {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:self.dbPath];
    if ([db open]) {
        return db;
    }
    @throw [NSException exceptionWithName:@"DBException" reason:@"can not open DB" userInfo:nil];
}

- (NSInteger)getCurrentDBVersion {
    return 1;
}

@end
