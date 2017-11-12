//
//  ViewController.m
//  alert
//
//  Created by 匹诺曹 on 2017/11/12.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"
@interface ViewController ()
@property (nonatomic,strong) MyView *v;

@property (nonatomic,strong) HXDialog *d;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"tt" style:UIBarButtonItemStylePlain target:self action:@selector(click)];
    
    self.navigationItem.rightBarButtonItem = right;
    

}

- (void)quxiao {
    NSLog(@"quxiao");
    [self.d hide];
}

- (void)queding {
    NSLog(@"queding");
}


- (void)click {
    _v = [[NSBundle mainBundle] loadNibNamed:@"MyView" owner:nil options:nil][0];
    self.v.frame = CGRectMake(0, 0, 375 * 0.8, 200);
    [self.v.quxiao addTarget:self action:@selector(quxiao) forControlEvents:UIControlEventTouchUpInside];
    [self.v.queding addTarget:self action:@selector(queding) forControlEvents:UIControlEventTouchUpInside];
    

    self.d = [[HXDialog alloc] init];

    self.d.contentView = self.v;
    [self.d show];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
