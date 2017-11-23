//
//  TestViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/22.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "TestViewController.h"

#import "UAProgressView.h"
#import "UIColor+Hex.h"
#import "PNCProgressDialog.h"
#import "GradientLabel.h"
#import "OrdersStateView.h"

#import "CircleProgressView.h"
#import "CircleProgressView2.h"

#import "PNCProgressDialog.h"

@interface TestViewController ()

@property (nonatomic, assign) CGFloat localProgress;
@property (nonatomic,strong) PNCProgressDialog *dialog;
@property (nonatomic,strong) CircleProgressView * c;
@property (nonatomic,strong) CircleProgressView2 * c2;

@end

@implementation TestViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *str = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
    DLog(@"%@",str);

    
//     _c=  [[CircleProgressView alloc] initWithFrame:CGRectMake(100, 400, 66, 66)];
//    [self.view addSubview:_c];
//    
//    _c2=  [[CircleProgressView2 alloc] initWithFrame:CGRectMake(100, 200, 66, 66)];
//    [self.view addSubview:_c2];
//    
//    
//    OrdersStateView *v = [[OrdersStateView alloc] init];
//    [self.view addSubview:v];
//
//    [v mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.view.mas_top).with.offset(64);
//        make.left.mas_equalTo(self.view.mas_left);
//        make.right.mas_equalTo(self.view.mas_right);
//        make.height.mas_equalTo(60);
//    }];
    



//    self.view.layer insertSublayer:<#(nonnull CALayer *)#> atIndex:<#(unsigned int)#>
//    　　　　思路: 1)_ 新建label, 把label添加到view上(这个label图层作用也只是设置mask, 不用来显示)
//    
//    　　　　　　  2)_ 创建 CAGradientLayer, 设置其渐变色, 将其添加到 label 的superView的layer上, 并覆盖在label上
//    
//    　　　　　　  3)_ 设置 gradientLayer的mask为 label的layer 重新设置label的frame
    

    
  
//    _localProgress= 0;
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];

}

- (void)timerFired {
    _localProgress  += 5;
    [_c updateProgressWithNumber:_localProgress];
//    _localProgress = ((int)((_localProgress * 100.0f) + 1.01) % 100) / 100.0f;
//    
//    [self.progressView3 setProgress:_localProgress];
//    PNCProgressViewAlert *p =      (PNCProgressViewAlert*)_dialog.contentView;
//    [p.progressView setProgress:_localProgress];
}

@end
