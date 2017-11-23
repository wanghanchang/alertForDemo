//
//  CallRecorderHelper.h
//  PersonalRecord
//
//  Created by hzpnc on 16/7/22.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "EntityHelperBase.h"

@interface CallRecorderInSqlite : NSObject<EntityInSqlite>

@end

@class EntityCallRecorder;
@interface CallRecorderHelper : EntityHelperBase

+ (instancetype)helper;
//降序
- (NSArray *)listByOrderedDesc;
//升序
- (NSArray *)listByOrderedAsc;

//添加数据
//- (void)addEntity:(EntityCallRecorder *)entity WithRecordId:(NSString *)recordId;

//根据录音ID  更新数据
- (BOOL)updateEntityByKey:(NSString *)key value:(NSString *)value forRecordId:(NSString *)recordId;
//删除录音
- (void)deleteCallRecord:(NSString*)recordId;
@end

@interface EntityCallRecorder : NSObject
@property (nonatomic,assign) NSInteger entityId;
@property (nonatomic, copy) NSString *direction;    //拨打类型
@property (nonatomic, copy) NSString *download;     //下载次数
@property (nonatomic, copy) NSString *beginTime;    //通话的时间
@property (nonatomic, copy) NSString * duration;     //通话的时长
@property (nonatomic, copy) NSString* ext;        //录音类型
@property (nonatomic, copy) NSString * contactNumber;     //被叫人的电话号码
@property (nonatomic, copy) NSString *note;       //备注
@property (nonatomic, assign) BOOL   isCollect; //是否收藏
@property (nonatomic, copy) NSString *listen;     //试听次数
@property (nonatomic, strong) NSString *recordId;  //录音id
@property (nonatomic,strong) NSString *size;       //文件大小


@end