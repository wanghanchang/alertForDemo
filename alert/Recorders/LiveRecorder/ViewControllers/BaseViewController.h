//
//  BaseViewController.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/3/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationBar+BackColor.h"

#import "HTTPErrorAlert.h"
#import "PNCAlertStarDialog.h"
#import "PNCAlertDialog.h"
#import "PNCAutoAlertDialog.h"
#import "PNCDatePickerDialog.h"

@interface BaseViewController : UIViewController

@property BOOL isKeyboardShown;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edge;


-(void)runInMainQueue:(void (^)())block;
-(void)runInGlobalQueue:(void (^)())block;
-(void)runAfterSecs:(float)secs block:(void (^)())block;



@end
