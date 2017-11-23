//
//  PNCStarRatingView.h
//  Project61
//
//  Created by 匹诺曹 on 15/12/15.
//  Copyright © 2015年 hzpnc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNCStarRatingView;
@protocol PNCStarRateViewDelegate <NSObject>
@optional

- (void)starRateView:(PNCStarRatingView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;

@end

@interface PNCStarRatingView : UIView

@property (nonatomic, assign) CGFloat scorePercent;//得分值，范围为0--1，默认为0
@property (nonatomic, assign) BOOL hasAnimation;//是否允许动画，默认为NO
@property (nonatomic, assign) BOOL allowIncompleteStar;//评分时是否允许不是整星，默认为NO

@property (nonatomic, weak) id<PNCStarRateViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;

@end
