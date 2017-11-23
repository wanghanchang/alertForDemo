//
//  SqliteTable.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteTable : NSObject

+(instancetype)tableWithName:(NSString *)name withColumns:(NSArray *)columms withPrimaryKeyColumn:(NSString*)column;

@property (nonatomic,copy) NSString *tableName;
@property (nonatomic,retain) NSArray *columnsArray;
@property (nonatomic,copy) NSString *primaryKeyColumn;

- (NSString*)createTableSql;

@end
