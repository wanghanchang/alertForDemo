//
//  CircleProgressView.h
//  CircleProgress
//
//  Created by ln on 15/8/4.
//  Copyright (c) 2015年 xcgdb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressView : UIView


- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic,strong) UILabel *progressLabel;

- (void)updateProgressWithNumber:(float)number;
@end
