//
//  MessageHelper.h
//  PersonalRecord
//
//  Created by hzpnc on 16/8/24.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "EntityHelperBase.h"


@interface MessageInSqlite : NSObject<EntityInSqlite>

@end


@interface MessageHelper : EntityHelperBase

+ (instancetype)helper;

- (NSArray *)listByOrderedDesc;

- (void)updateEntity;

@end

@interface MessageEntity : NSObject

@property (nonatomic,assign) NSInteger entityId;

@property (nonatomic, strong) NSString *messageTime;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSString *messageContent;

@end
