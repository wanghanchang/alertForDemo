//
//  SqliteQuery.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteQuery : NSObject

@property (nonatomic,copy) NSString *table;
@property (nonatomic,retain) NSArray *columns;

@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *asc;

@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger offset;

@property (nonatomic,retain) NSDictionary *match;

@property (nonatomic,copy) NSString *selection;

+ (SqliteQuery*)queryWithTable:(NSString*)table forColumns:(NSArray*)columns;

+ (SqliteQuery*)queryWithTable:(NSString *)table forColumns:(NSArray *)columns whereMatches:(NSDictionary*)matches;

+ (SqliteQuery*)queryWithTable:(NSString*)table whereMatches:(NSDictionary *)matches;

+ (SqliteQuery*)queryWithTable:(NSString *)table forColumns:(NSArray *)columns whereMatches:(NSDictionary *)matches withDesc:(NSString*)desc;

- (NSString*) querySQL;

- (NSString*) deleteSQL;

@end
