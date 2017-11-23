//
//  LiveRecordHelper.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/28.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "EntityHelperBase.h"

typedef NS_ENUM(NSUInteger,TranslateStatus) {
    Translate_Unpay    = 0,
    Translate_Translating     = 1,
    Translate_Done   = 2,
};

@interface LiveRecordInSqlite : NSObject<EntityInSqlite>

@end

@interface LiveRecordHelper : EntityHelperBase

+ (instancetype)helper;

- (NSArray*)listByRecordState:(TranslateStatus)state;

- (NSArray*)listByRecordTag:(NSString*)Tag;

- (NSArray *)listByNoArrayData:(NSMutableArray *)array;

- (NSArray*)listAllDesc;

- (NSArray*)listByOrderId:(NSString*)orderId;

@end

@interface EntityLiveRecord : NSObject

@property (nonatomic,assign) NSInteger entityId;
@property (nonatomic,assign) long startTime;
@property (nonatomic,assign) int timeLong;
@property (nonatomic,assign) long fileLength;
@property (nonatomic,copy) NSString *fileName;  //存的实际文件名字(用于读取该路径文件)
@property (nonatomic,copy) NSString *userNamedFile; //用户命名
@property (nonatomic,copy) NSString *expandName;
@property (nonatomic,copy) NSString* recordTagColor;
@property (nonatomic,copy) NSString* recordTag;

//上传
@property (nonatomic,assign) TranslateStatus translateState; //订单(翻译)状态;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString* fileId;
@property (nonatomic,assign) BOOL isFinishUplaod;  //这个值判定上传完成
@property (nonatomic,assign) BOOL isFinishBindOrder;  //这个判断上传完成并且与订单绑定
@property (nonatomic,copy) NSString *resultTransStr;  //字符串

@end
