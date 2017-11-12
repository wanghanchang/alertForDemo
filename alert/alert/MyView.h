//
//  MyView.h
//  alert
//
//  Created by 匹诺曹 on 2017/11/12.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXDialog.h"
@interface MyView : UIView
@property (weak, nonatomic) IBOutlet UIButton *quxiao;
@property (weak, nonatomic) IBOutlet UIButton *queding;
@property (weak) HXDialog *dilog;
@end
