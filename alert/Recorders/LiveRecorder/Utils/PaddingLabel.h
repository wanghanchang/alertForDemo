//
//  PaddingLabel.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/3.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaddingLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

- (id)initWithFrame:(CGRect)frame;
@end
