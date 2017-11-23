//
//  TestView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/23.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scoll = [[UIScrollView alloc] initWithFrame:frame];
        self.v = [[UIView alloc] initWithFrame:frame];
        self.scoll.backgroundColor = [UIColor yellowColor];
        
self.v.backgroundColor = [UIColor redColor];
        
        [self addSubview:self.scoll];
        [self.scoll addSubview:self.v];
        
    }
    return self;

}
@end
