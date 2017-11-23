//
//  UpLoadTranslate.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/4.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "UpLoadTranslate.h"
#import <QiniuSDK.h>
#import "CommonUtils.h"
#import <QNFile.h>

static UpLoadTranslate *translate = nil;

@implementation UpLoadTranslate

static QNUploadManager *upManager;

+ (UpLoadTranslate*)translate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        translate = [[UpLoadTranslate alloc] init];
    });
    return translate;
}

- (void)getTokenWithReturnKeyBlock:(void (^)(int, UpLoadEntity *))block {
    NSString *token = @"/v1/uploads/qiniu-token";
    [BaseRequest getWithRequsetURL:token withParameter:nil withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *resultDic = (NSDictionary*)obj;
        
        UpLoadEntity *entity = [[UpLoadEntity alloc] init];
        entity.encrypt = [resultDic[@"encrypt"] intValue];
        entity.fileId = resultDic[@"fileId"];
        entity.md5 = resultDic[@"md5"];
        entity.uploadToken = resultDic[@"uploadToken"];
        entity.testInfo = resultDic[@"testInfo"];
        block([resultDic[@"result"] intValue],entity);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,nil);
    } withFailureBlock:^{        
    }];
}

- (void)getOrderIdWithReturnKeyBlock:(void(^)(int a,NSString *orderId))block {
    
    NSString *token = @"/v1/orders/order-id";
    [BaseRequest getWithRequsetURL:token withParameter:nil withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *resultDic = (NSDictionary*)obj;
        block([resultDic[@"result"] intValue],resultDic[@"sysOrderId"]);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,nil);
    } withFailureBlock:^{
    }];
    
}

- (void)uploodQiNiu:(NSString*)token WithFileId:(NSString *)fileId WithEntity:(EntityLiveRecord *)entity  WithState:(void (^)(int))block withProgressBlock:(void (^)(float))progress {
    __block float pos;
    __block float size;

    NSString *p =  [CommonUtils generateFilePathWithFileName:entity.fileName andFileManagerName:[[AccountInfo shareInfo] mobile] isTxt:NO];
    
    NSString *path;
    NSString *footer;
    if (entity.timeLong == 1) {
        path = [p stringByAppendingString:@".wav"];
        footer = @"wav";
    } else {
        path = [p stringByAppendingString:@".mp3"];
        footer = @"mp3";
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *dic = @{ @"x:ext":footer,
                           @"x:fileId":fileId,
                           @"x:rectime":[NSString stringWithFormat:@"%@",[CommonUtils currentTimeSince1970WithUpLoadType:entity.startTime]],
                           @"x:note" : entity.userNamedFile,
                           @"x:size" : [NSString stringWithFormat:@"%ld",data.length],
                           @"x:seconds":[NSString stringWithFormat:@"%d",entity.timeLong],
                           @"x:uid":[NSString stringWithFormat:@"%@",[[AccountInfo shareInfo] uid]]
                           };
    
    NSLog(@"%@",dic);
    
    NSError *error = nil;
    QNFileRecorder *file;
    NSString *uploadInfoPath = [p stringByAppendingString:@"uploadInfo"];
    NSFileManager* fm=[NSFileManager defaultManager];
    pos = 0.0;

    if ( [fm fileExistsAtPath:uploadInfoPath]) {
        NSArray *files = [fm subpathsAtPath:uploadInfoPath];
        if (files.count> 0) {
            NSString *filePath = [uploadInfoPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[files lastObject]]];
            NSDictionary *dic = [CommonUtils getJsonDataToDicByPath:filePath];
            size = [dic[@"size"] floatValue];
            pos = [dic[@"offset"] floatValue];
        }
    }
    
    file = [QNFileRecorder fileRecorderWithFolder:[p stringByAppendingString:@"uploadInfo"] error:&error];
    upManager = [[QNUploadManager alloc] initWithRecorder:file];

    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.chunkSize = 256 * 1024;
        builder.recorder = file;
    }];
    upManager = [[QNUploadManager alloc] initWithConfiguration:config];

    QNUploadOption *opt;
//停止~
    NSString *qiniuFileIdWithMP3;
    if (entity.timeLong == 1) {
        qiniuFileIdWithMP3 = [NSString stringWithFormat:@"%@.wav",fileId];
    } else {
        qiniuFileIdWithMP3 = [NSString stringWithFormat:@"%@.mp3",fileId];
    }

    DLog(@"%@",qiniuFileIdWithMP3);
    if (pos == 0) {
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(percent);
            });
        } params:dic checkCrc:NO cancellationSignal:^BOOL{
            return self.stop;
        }];
        [upManager putFile:path key:qiniuFileIdWithMP3 token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.isOK) {
                DLog(@"请求成功");
                block(HTTP_OK);
            } else if (info.isCancelled) {
                DLog(@"用户取消");
            } else {
                DLog(@"失败");
                //如果失败，这里可以把info信息上报自己的服务器，便于后面分析上传错误原因
                block(UPLOAD_BAD);
            }
            DLog(@"info ===== %@", info);
            DLog(@"resp ===== %@", resp);
        } option:uploadOption];
    } else {
        __block BOOL failed = NO;
        opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            if (percent < pos - (256 * 1024.0) / size) {
                failed = YES;
            }
            progress(percent);
            DLog(@"continue progress %f", percent);
        }
                                            params:dic
                                          checkCrc:NO
                                cancellationSignal:^BOOL{
                                    return self.stop;
        }];
        [upManager putFile:path key:qiniuFileIdWithMP3 token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.isOK) {
                DLog(@"请求成功");
                block(HTTP_OK);
            } else if (info.isCancelled) {
                DLog(@"用户取消");
            } else {
                DLog(@"失败");
                //如果失败，这里可以把info信息上报自己的服务器，便于后面分析上传错误原因
                block(UPLOAD_BAD);
            }
            DLog(@"info ===== %@", info);
            DLog(@"resp ===== %@", resp);
        } option:opt];
    }

}


- (void)getShareUrlWithFieldId:(NSString *)fieldId Block:(void (^)(NSString *, int))block {
    NSString *token = @"/v1/downloads/share-url";
    NSDictionary *param = @{@"fileId" : fieldId};
    [BaseRequest getWithRequsetURL:token withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *resultDic = (NSDictionary*)obj;
        block(resultDic[@"shareUrl"],HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        
    } withFailureBlock:^{
        
    }];
}


@end

@implementation UpLoadEntity


@end
