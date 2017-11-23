//
//  EntityInSqlite.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;
@class NSDictionary;

@protocol EntityInSqlite <NSObject>

@optional

- (id)entityFromResultSet:(FMResultSet*) resultSet;

- (NSDictionary *)contentValuesFromEntity:(id)entity;

@end
