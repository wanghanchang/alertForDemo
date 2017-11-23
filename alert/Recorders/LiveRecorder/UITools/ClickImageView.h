//
//  ClickImageView.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/7/3.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClickImageView : UIImageView
{
    id _target;
    SEL _selector;
    UIControlEvents _controlEvent;            
}

-(void)addTarget:(id)tag action:(SEL)sel forControlEvent:(UIControlEvents)event;

@end
