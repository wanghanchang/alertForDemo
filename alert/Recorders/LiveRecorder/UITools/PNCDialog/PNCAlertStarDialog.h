//
//  PNCAlertStarDialog.h
//  Project61
//
//  Created by 匹诺曹 on 15/12/23.
//  Copyright © 2015年 hzpnc. All rights reserved.
//

#import "PNCDialog.h"
#import "PNCDialogView.h"
#import "PNCStarRatingView.h"

@interface PNCAlertStarView : PNCDialogView

@property NSString* title;
@property NSString* message;
@property NSArray*  buttonTitles;
@property(copy) PNCDialogButtonTapEvent event;
@property (nonatomic,strong) UIButton *button2;

@property UILabel*  titleLabel;
@property UILabel*  messageLabel;
@property PNCStarRatingView *starRatingView;
@property UIView*   buttonContainer;
@property (nonatomic,strong) UILabel *alertLabel;
@property (nonatomic,strong) UIView *spliterline;

@property (nonatomic,strong) UIView *spliterMidLine;

@property(weak) PNCDialog* dialog;

@end

@protocol StarScoreDelegate <NSObject>

- (void)starScoreView:(PNCStarRatingView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;

@end

@interface PNCAlertStarDialog : PNCDialog <PNCStarRateViewDelegate>

@property (nonatomic,assign) id<StarScoreDelegate> delegate;

+ (instancetype)alertWithStarRating:(NSString*)title
                         andMessage:(NSString*)message
               containsButtonTitles:(NSArray*)buttonTitles
               andStarScoreDelegate:(id<StarScoreDelegate>)delegate
               buttonTapEventsBlock:(PNCDialogButtonTapEvent)event;

@end
