//
//  AppDelegate.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/20.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "LoginViewController.h"
#import "MyViewController.h"
#import "RecordFileViewController.h"

#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
#import "UIWindow+Ext.h"
#import "WXApi.h"
#import <AFNetworking.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WechatQQRequest.h"
#import "PlayViewController.h"
#import "PNCDBHelper.h"
#import "OrdersViewController.h"
 #import "PhoneBindingViewController.h"
#import "OrdersRequest.h"
#import "PhoneBindingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "OrderStateViewController.h"
#import "TranslateTxtViewController.h"
#import "PNCAlertDialog.h"
#import "PlayViewController.h"

#define UMAppKey @"57c63ade67e58e8435001e82"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface AppDelegate ()<WXApiDelegate,UNUserNotificationCenterDelegate> {
    LoginViewController *loginVC;
}
@end

//进去上传后没有及时上传 那个时候推出  再上传抱40006
//40001

dispatch_source_t _timer;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UMessage startWithAppkey:UMAppKey launchOptions:launchOptions];
    [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:nil];
    [self configUMNotification];
    
    [WXApi registerApp:WECHAT_APP_ID];
    if ([[AccountInfo shareInfo] mobile].length > 0 && [[AccountInfo shareInfo] uid] != nil) {
        [self initRootViewController];
    } else {
        [self login];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    AudioSessionInitialize(NULL, NULL, interruptionListenner, (__bridge void*)self);
    
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),NULL, screenLockStateChanged,NotificationLock,NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
//    
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),NULL, screenLockStateChanged,NotificationChange,NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    self.isBackGround = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeHome:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    return YES;
}

- (void)comeHome:(UIApplication *)application {
        DLog(@"进入后台");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    MainViewController *c =  [MainViewController controller];
    if (c.currentState == AudioQueueState_Recording) {
        [c addCurrentRecord];
    }
    DLog(@"程序被杀死");
}

//static void screenLockStateChanged(CFNotificationCenterRef center,void* observer,CFStringRef name,const void* object,CFDictionaryRef userInfo){
//    
//    NSString* lockstate = (__bridge NSString*)name;
//    
//    if ([lockstateisEqualToString:(__bridge NSString*)NotificationLock]) {
//        NSLog(@"锁屏");
//    }else{
//        NSLog(@"状态改变了");
//    }
//}


//void interruptionListenner(void* inClientData, UInt32 inInterruptionState)
//{
//    AppDelegate* pTHIS = (__bridge AppDelegate*)inClientData;
//    float time = 0.0;
//    if (pTHIS) {
//        DLog(@"interruptionListenner %u", (unsigned int)inInterruptionState);
//        if (kAudioSessionBeginInterruption == inInterruptionState) {
//            DLog(@"Begin interruption");
//        } else {
//            DLog(@"Begin end interruption");
//            DLog(@"time2 = %.2f", time);
//            [[PlayViewController player] setCurrentTime:time];
//            [[PlayViewController player] play];
//            DLog(@"End end interruption");
//        }
//        
//    }
//}



- (void)configUMNotification {
    [UMessage registerForRemoteNotifications];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                DLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    DLog(@"%@",settings);
                }];
            } else {
                DLog(@"注册失败");
            }
        }];
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"打开应用";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"忽略";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        UIMutableUserNotificationCategory *actionCategory1 = [[UIMutableUserNotificationCategory alloc] init];
        actionCategory1.identifier = @"category1";//这组动作的唯一标示
        [actionCategory1 setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        NSSet *categories = [NSSet setWithObjects:actionCategory1, nil];
        [UMessage registerForRemoteNotifications:categories];
    }
    [UMessage setLogEnabled:YES];
    
    
    if ([[[UIDevice currentDevice] systemVersion]intValue]>=10) {
        UNNotificationAction *action1_ios10 = [UNNotificationAction actionWithIdentifier:@"action1_ios10_identifier" title:@"打开应用" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2_ios10 = [UNNotificationAction actionWithIdentifier:@"action2_ios10_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];
        
        //UNNotificationCategoryOptionNone
        //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
        //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
        UNNotificationCategory *category1_ios10 = [UNNotificationCategory categoryWithIdentifier:@"category101" actions:@[action1_ios10,action2_ios10]   intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        NSSet *categories_ios10 = [NSSet setWithObjects:category1_ios10, nil];
        [center setNotificationCategories:categories_ios10];
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"\n\n\n%@\n\n",[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]);
    [UMessage registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"fail to register");
}

//iOS10以下使用这个方法接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    [self dealUserinfo:userInfo];
//定制自定的的弹出框
//        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"标题"
//                                                                message:@"Test On ApplicationStateActive"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"确定"
//                                                      otherButtonTitles:nil];
//    
//            [alertView show];
//    
//        }

}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request;
//    UNNotificationContent *content = request.content;
//    NSNumber *badge = content.badge;
//    NSString *body = content.body;
//    UNNotificationSound *sound = content.sound;
//    NSString *subtitle = content.subtitle;
//    NSString *title = content.title;
    
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [self dealUserinfo:userInfo];
    }else{
        //判断为本地通知
        DLog(@"iOS10 前台收到本地通知");
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

- (void)dealUserinfo:(NSDictionary*)userInfo {
    UIViewController* controller = [[[UIApplication sharedApplication] keyWindow] visibleViewController];
    
    NSString *action =  userInfo[@"custom"][@"action"];
    if ([action isEqualToString:@"notification"]) {
        
    }
    if ([action isEqualToString:@"logout"]) {
        //            NSString *timestamp = userInfo[@"custom"][@"timestamp"];
    }
    
    if ([action isEqualToString:@"trans"]) {
        NSString *orderId = userInfo[@"custom"][@"orderId"];
        LiveRecordHelper *helper = [LiveRecordHelper helper];
        NSArray *arr = [helper listByOrderId:orderId];
        
        if ([controller isKindOfClass:[LoginViewController class]]) {
            //已退出直接无作为
            return ;
        } else if ([controller isKindOfClass:[MainViewController class]]) {
            MainViewController *mvc = (MainViewController *)controller;
            if (mvc.currentState == AudioQueueState_Recording) {
                //只是做提示但是不跳转
                //让他自己去订单已完成去跳转
                [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"文字转写完毕,检测到正在录音,请到订单-已完成查看" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                    if (buttonIndex == 0) {
                        [dialog hide];
                    }
                }] show];
            } else {
                if (arr.count == 1) {
                    //跳转play
                    [self goNewPlayVCWithCurrentController:controller andEntity:arr[0]];
                } else {
                    //本地无文件
                    [self goOrderStatusVCWithNoFileIdLocal:controller withOrderId:orderId];
                }
            }
        } else if ([controller isKindOfClass:[PlayViewController class]]) {
            PlayViewController *pvc = (PlayViewController *)controller;
            if (arr.count == 1) {
                if ([pvc.entity.orderId isEqualToString:orderId]) {
                    [pvc reloadTranslate];
                } else {
                    [self goNewPlayVCWithCurrentController:controller andEntity:arr[0]];
                }
            } else {
                [self goOrderStatusVCWithNoFileIdLocal:controller withOrderId:orderId];
            }
        } else {
            if (arr.count == 1) {
                [self goNewPlayVCWithCurrentController:controller andEntity:arr[0]];
            } else {
                [self goOrderStatusVCWithNoFileIdLocal:controller withOrderId:orderId];
            }
        }
    }
}

- (void)goNewPlayVCWithCurrentController:(UIViewController*)controller andEntity:(EntityLiveRecord *)entity {
    
    [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"文字转写完毕,前往查看或者到订单已完成查看" containsButtonTitles:@[@"前往",@"取消"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
        if (buttonIndex == 0) {
            UINavigationController *navifile =  controller.navigationController.tabBarController.childViewControllers[1];
            [navifile popToRootViewControllerAnimated:NO];
            navifile.tabBarController.selectedIndex = 1;
            
            PlayViewController *play = [[PlayViewController alloc] initWithFileName:entity];
            play.seeTranslate = YES;
            [navifile pushViewController:play animated:YES];
        }
        [dialog hide];
    }] show];
}

- (void)goOrderStatusVCWithNoFileIdLocal:(UIViewController *)controller withOrderId:(NSString*)orderId {
    
    [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"文字转写完毕,前往查看或者到订单已完成查看" containsButtonTitles:@[@"前往",@"取消"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
        if (buttonIndex == 0) {
            UINavigationController *navifile =  controller.navigationController.tabBarController.childViewControllers[1];
            [navifile popToRootViewControllerAnimated:NO];
            navifile.tabBarController.selectedIndex = 1;

            OrderStateViewController *v = [[OrderStateViewController alloc] initWithSysOrderId:orderId];
            [navifile pushViewController:v animated:YES];
        }
        [dialog hide];
    }] show];
}



//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [self dealUserinfo:userInfo];
    }else{
        //应用处于后台时的本地推送接受
    }
}


- (void)login {
    loginVC= [[LoginViewController alloc] init];
    UINavigationController *naviMain = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = naviMain;
    [self.window makeKeyAndVisible];
}

- (void)logout {
    [[AccountInfo shareInfo] cleanCurrentProfile];
    [UMessage removeAlias:[[AccountInfo shareInfo] uid] type:@"alias_uid" response:nil];
    
    loginVC= [[LoginViewController alloc] init];
    UINavigationController *naviMain = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = naviMain;
    [self.window makeKeyAndVisible];
}

- (void)initRootViewController {
    [PNCDBHelper switchToDBNamed:[[AccountInfo shareInfo] mobile]];

    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    attrs[NSForegroundColorAttributeName] = GrayColor;
    
    NSMutableDictionary *attrSelected = [NSMutableDictionary dictionary];
    attrSelected[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    attrSelected[NSForegroundColorAttributeName] = RedColor;
    
    MainViewController *main = [MainViewController controller];
    UINavigationController *naviMain = [[UINavigationController alloc] initWithRootViewController:main];
    UIImage *navi_Main_s = [UIImage imageNamed:@"record_tab_icon_selected"];
    navi_Main_s = [navi_Main_s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    naviMain.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"录音文件" image:[UIImage imageNamed:@"record_tab_icon"] selectedImage:navi_Main_s];
    [naviMain.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [naviMain.tabBarItem setTitleTextAttributes:attrSelected forState:UIControlStateSelected];

    
    
    RecordFileViewController *recordFile = [[RecordFileViewController alloc] init];
    UINavigationController *naviRecordFile = [[UINavigationController alloc] initWithRootViewController:recordFile];
    UIImage *record_file_s = [UIImage imageNamed:@"recordfile_tab_icon_selected"];
    record_file_s = [record_file_s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    naviRecordFile.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"录音文件" image:[UIImage imageNamed:@"recordfile_tab_icon"] selectedImage:record_file_s];
    [naviRecordFile.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [naviRecordFile.tabBarItem setTitleTextAttributes:attrSelected forState:UIControlStateSelected];
    
    
    
    OrdersViewController *order = [[OrdersViewController alloc] init];
    UINavigationController *naviOrders = [[UINavigationController alloc] initWithRootViewController:order];
    UIImage *navi_Order_s = [UIImage imageNamed:@"my_orders_selected"];
    navi_Order_s = [navi_Order_s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    naviOrders.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"订单" image:[UIImage imageNamed:@"my_orders"] selectedImage:navi_Order_s];
    [naviOrders.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [naviOrders.tabBarItem setTitleTextAttributes:attrSelected forState:UIControlStateSelected];


    
    MyViewController *My = [[MyViewController alloc] init];
    UINavigationController *naviMy = [[UINavigationController alloc] initWithRootViewController:My];
    UIImage *navi_My_s = [UIImage imageNamed:@"my_tab_icon_selected"];
    navi_My_s = [navi_My_s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    naviMy.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"my_tab_icon"] selectedImage:navi_My_s];
    [naviMy.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [naviMy.tabBarItem setTitleTextAttributes:attrSelected forState:UIControlStateSelected];

    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:naviMain,naviRecordFile,naviOrders,naviMy, nil];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            }];
    
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
                DLog(@"result ====== %@",resultDic);
                // 解析 auth code
                NSString *result = resultDic[@"result"];
                NSString *authCode = nil;
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                DLog(@"授权结果 authCode = %@", authCode?:@"");
            }];
            return YES;
        }
    [WXApi handleOpenURL:url delegate:self];
    [TencentOAuth HandleOpenURL:url];
    return YES;
}

//微信授权回调
- (void)onResp:(BaseResp *)resp {    
    if (loginVC != nil) {
        [loginVC getResp:resp];
    }
    if([resp isKindOfClass:[PayResp class]]){
//支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess: {
                NSNotification *notice = [NSNotification notificationWithName:@"wechatPay" object:SUCCESS_PAY userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notice];
            }
                break;
            default: {
                NSNotification *notice = [NSNotification notificationWithName:@"wechatPay" object:FAIL_PAY userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notice];
            }
                break;
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.isBackGround = YES;
    MainViewController *main = [MainViewController controller];
    if (main.currentState == AudioQueueState_Recording) {
        main.link.paused = YES;
        UIApplication*   app = [UIApplication sharedApplication];
        __block    UIBackgroundTaskIdentifier bgTask;
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bgTask != UIBackgroundTaskInvalid)
                {
                    bgTask = UIBackgroundTaskInvalid;
                }
            });
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bgTask != UIBackgroundTaskInvalid)
                {
                    bgTask = UIBackgroundTaskInvalid;
                }
            });
        });
        
        float a = 1.0 * NSEC_PER_SEC / 30.0;
        CreateDispatchTimer(a, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateTime];
        });
    }
}

dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                    dispatch_queue_t queue,
                                    dispatch_block_t block)
{
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                         0, 0, queue);
        if (_timer)
        {
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
            dispatch_source_set_event_handler(_timer, block);
            dispatch_resume(_timer);
        }
        return _timer;
}

- (void)stopTimer {
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)updateTime {
    MainViewController *main =  [MainViewController controller];
    main.sec += 1;
    main.draw.bias += 1.0;
    float creationFloat = 50.0 * ADJUSTWIDTH;
    if (main.numData) {
        if (main.sec < 4) {
            [main.draw.dataArray addObject:[NSNumber numberWithFloat:0.0]];
        } else {
            if (main.myData.isNewData == YES) {
                int max = 0;
                for ( int i= 0 ; i < 1024 / 3 * main.myData.times ; i ++ ) {
                    max =  max > main.numData[i] ? max : main.numData[i];
                }
                main.myData.isNewData = NO;
                float value;
                
                if (max > 16383.50) {
                    value =  (max - 16383.50) / 16383.50 * creationFloat / 2 + creationFloat;
                } else {
                    value = max / 16383.50 * creationFloat;
                }
                [main.draw.dataArray addObject:[NSNumber numberWithFloat:value]];
                main.myData.times ++;
            } else {
                int max = 0;
                for ( int i= 0 ; i < 1024 / 3 * main.myData.times ; i ++ ) {
                    max =  max > main.numData[i] ? max : main.numData[i];
                }
                float value;
                if (max > 16383.50) {
                    value =  (max - 16383.50) / 16383.50 * creationFloat /2 + creationFloat;
                } else {
                    value = max / 16383.50 * creationFloat;
                }
                [main.draw.dataArray addObject:[NSNumber numberWithFloat:value]];
                main.myData.times ++;
                if (main.myData.times > 3) {
                    main.myData.times = 3;
                }
            }
        }
    } else {
        [main.draw.dataArray addObject:[NSNumber numberWithFloat:0.0]];
    }
//    NSLog(@"c = %d",main.sec);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.isBackGround = NO;
    MainViewController *main = [MainViewController controller];
    if (_timer != nil && main.currentState == AudioQueueState_Recording) {
        [self stopTimer];
        main.link.paused = NO;
    }
    
    float time = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isPlaying"] floatValue];
    if (time && time > 0) {
        if ([PlayViewController player]) {
            [[PlayViewController player] setCurrentTime:time];
            NSNotification *notice = [NSNotification notificationWithName:@"isPlaying" object:@"refreshP" userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notice];
        }
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isPlaying"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    float time2 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isRecording"] floatValue];
    if (time2 && time2 > 0) {
        NSNotification *notice = [NSNotification notificationWithName:@"isRecording" object:[NSNumber numberWithFloat:time2] userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notice];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isRecording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}




@end
