//
//  EntityHelper.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSArray;

@protocol EntityHelper <NSObject>

@required

- (NSArray*) list;

- (id)get:(NSInteger)entityId;

- (NSInteger)add:(id)entity;

- (NSInteger)addAll:(NSArray*)entities;

- (BOOL)updateEntity:(id)entity forEntityId:(NSInteger)entityId;

- (NSInteger)remove:(NSInteger)entityId;

- (void)clear;

@end
