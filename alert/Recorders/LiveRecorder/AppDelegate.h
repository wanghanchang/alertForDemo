//
//  AppDelegate.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/20.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)logout;
- (void)initRootViewController;
- (void)stopTimer;
@property (nonatomic,assign) BOOL isBackGround;

@end

