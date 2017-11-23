//
//  ClickImageView.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/7/3.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "ClickImageView.h"

@implementation ClickImageView
-(void)addTarget:(id)tag action:(SEL)sel forControlEvent:(UIControlEvents)event
{
    _target = tag;
    _selector = sel;
    _controlEvent = event;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_controlEvent == UIControlEventTouchDown) {
        [_target performSelector:_selector withObject:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //如果不这么结耦合,那么在touchEnd就会让所有的touchEnd过程执行一个内容,控制不了,这样通过点击_target self自己而写出一个方法_selector的结耦合;  其实是把touchend拆开了, 拆成一个点击对象, 一个点击过程touchinsideup 一个点击过程执行的方法;
    if (_controlEvent == UIControlEventTouchUpInside) {
        //响应某个方法
        [_target performSelector:_selector withObject:self];
    }
}

@end
