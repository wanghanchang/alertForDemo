//
//  BaseViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseViewController.h"
#import <AFNetworkReachabilityManager.h>
@interface BaseViewController ()
@property CGRect originFrame;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];Ø
    
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态发生改变的时候调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                DLog(@"WIFI");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                DLog(@"自带网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                DLog(@"没有网络");
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                DLog(@"未知网络");
                break;
            default:
                break;
        }
    }];
    // 开始监控
    [mgr startMonitoring];
    
    
    self.view.backgroundColor = WhiteColor;
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 10.0) { // iOS系统版本 >= 8.0
        [self.navigationController.navigationBar setColor:WhiteColor];
    } else {
        //iOS系统版本 < 8.0
    }
    

#pragma Keyboard
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
//    self.edge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(backToUp)];
//    self.edge.edges = UIRectEdgeLeft;
//    [self.view addGestureRecognizer:self.edge];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyDuration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self keyboardWillShowWithRect:keyboardRect inSeconds:keyDuration];
    self.isKeyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyDuration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self keyboardWillHideWithRect:keyboardRect inSeconds:keyDuration];
    self.isKeyboardShown = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.originFrame = self.view.frame;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)tapToCloseKeyboard {
    [self.view endEditing:YES];
}

- (void)customeBackButton {
    
}

- (BOOL)shouldShowNavigationBar {
    return YES;
}


- (void)keyboardWillShowWithRect:(CGRect)rect inSeconds:(NSTimeInterval)seconds {
    CGFloat offset = [self offsetToMoveWhileKeybordShowWithRect:rect];
    if(offset > 0) {
        [UIView animateWithDuration:seconds animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (CGFloat)offsetToMoveWhileKeybordShowWithRect:(CGRect)rect {
    UIView* responder = [self currentResponder];
    CGRect frame = [responder convertRect:responder.bounds toView:self.view];
    CGFloat offset = (frame.origin.y + frame.size.height) - (rect.origin.y);
    if([self shouldPlusStatusBarAndNavigationBarHeight]) {
        CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
        CGRect navigationBarRect = self.navigationController.navigationBar.frame;
        return offset + (statusBarRect.size.height + navigationBarRect.size.height);
    }
    return offset;
}

- (void)keyboardWillHideWithRect:(CGRect)rect inSeconds:(NSTimeInterval)seconds {
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBarRect = self.navigationController.navigationBar.frame;
    CGFloat originY = [self shouldPlusStatusBarAndNavigationBarHeight] ? (statusBarRect.size.height + navigationBarRect.size.height) : 0;
    if(self.view.frame.origin.y < originY) {
        [UIView animateWithDuration:seconds animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, originY, self.view.frame.size.width, self.view.frame.size.height);
            //            self.view.frame = self.originFrame;
        }];
    }
}

- (UIView*)currentResponder {
    __block UIView* target = nil;
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* view = obj;
        if([view isFirstResponder]) {
            target = view;
            *stop = YES;
        }
    }];
    
    return target;
}

- (BOOL)shouldPlusStatusBarAndNavigationBarHeight {
    return NO;
}



-(void)runInMainQueue:(void (^)())block{
    dispatch_async(dispatch_get_main_queue(), block);
}

-(void)runInGlobalQueue:(void (^)())block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), block);
}

-(void)runAfterSecs:(float)secs block:(void (^)())block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs*NSEC_PER_SEC), dispatch_get_main_queue(), block);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
