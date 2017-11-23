//
//  PhoneBindingViewController.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/5.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface PhoneBindingViewController : BaseViewController

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *theId;

- (instancetype)initWithdAuthType:(NSString*)type withId:(NSString*)theId;

@end
