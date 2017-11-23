//
//  Tables.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteTable.h"
#import "SqliteColumn.h"


#define TableRecord   @"tableRecord"
#define kColID        @"colID"
#define kFileName     @"fileName"
#define kOrderId     @"orderId"
#define kFileLength   @"fileLength"
#define kfileId       @"fileId"
#define kisFinishUplaod @"isFinishUplaod"
#define kisFinishBindOrder @"isFinishBindOrder"
#define kresultTransStr     @"resultTransStr"
#define kExpandName   @"expandName"
#define kTranslateState  @"translateState"
#define kStartTime    @"startTime"
#define ktimeLong      @"timeLong"
#define kRecordTagColor   @"recordTagColor"
#define kRecordTag   @"recordTag"
#define kuserNamedFile @"userNamedFile"
//#define kRecordTime   @"recordTime"


#define kTableCallRecorder      @"tableCallRecorder"
#define kDirection              @"direction"        ////拨打类型
#define kDownload               @"download"         //下载次数
#define kBegintime              @"beginTime"        //通话的时间
#define kDuration               @"duration"         //通话的时长
#define kExt                    @"sid"              //录音类型
#define kContactNumber          @"contactNumber"    //被叫人的电话号码
#define kNote                   @"note"             //备注
#define kIsCollect              @"isCollect"        //收藏
#define kListen                 @"listen"           //试听次数
#define kRecordid               @"recordId"         //录音ID
#define KSize                   @"size"             //文件大小


//message
#define kMessage            @"message"
#define kMessageTime        @"messageTime"
#define kMessageIsNew       @"messageIsNew"
#define kMessageContent     @"messageContent"

@interface Tables : NSObject

+ (SqliteTable*)tableRecord;

+ (SqliteTable*)callRecorder;

+ (SqliteTable *)message;


@end
