//
//  EntityHelperBase.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMResultSet.h>
#import "EntityInSqlite.h"
#import "EntityHelper.h"
#import "SqliteQuery.h"
#import "Tables.h"
#import "PNCDBHelper.h"

#define TYPE_TEXT(val)  val ? [NSString stringWithFormat:@"\"%@\"", val] : @"\"\""


typedef id(^EntityFromDB)(FMResultSet*);
typedef NSDictionary*(^ContentValuesFromEntity)(id);

@interface EntityInSqliteBase : NSObject <EntityInSqlite>

@property (nonatomic,copy) EntityFromDB entityFromDBBlcok;
@property (nonatomic,copy) ContentValuesFromEntity ContentValuesFromEntityBlock;

+ (instancetype)instanceWithEntityFromDBBlock:(EntityFromDB)block1 andContentValuesFromEntityBlcok:(ContentValuesFromEntity)block2;

+ (instancetype)instanceWithEntityFromDBBlcok:(EntityFromDB )block;
+ (instancetype)instanceWithContentValuesFromEntity:(ContentValuesFromEntity)block;

@end


@interface EntityHelperBase : NSObject<EntityHelper>

- (instancetype)initWithDBHelper:(PNCDBHelper*) helper;

@property (nonatomic,strong) PNCDBHelper *helper;

- (NSString*)tableName;

- (NSString*)primaryKeyColumn;

- (id<EntityInSqlite>)wrapper;


@end
