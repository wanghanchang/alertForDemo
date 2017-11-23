//
//  PNCAlertStarDialog.m
//  Project61
//
//  Created by 匹诺曹 on 15/12/23.
//  Copyright © 2015年 hzpnc. All rights reserved.
//

#import "PNCAlertStarDialog.h"
#import "PNCAlertDialog.h"

#define CriterionSpace          16
#define kTextFont               18
#define kMessagePadding         20
#define kButtonHeight           44

@implementation PNCAlertStarView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc] init];
        self.buttonContainer = [[UIView alloc] init];
        self.starRatingView = [[PNCStarRatingView alloc] initWithFrame:CGRectMake(15, 50, 250, 40) numberOfStars:5];
        return self;
    }
    return nil;
}

- (UILabel *)alertLabel {
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.font = [UIFont systemFontOfSize:10.0];
        _alertLabel.textColor = [UIColor redColor];
        _alertLabel.text = @"(温馨提示:至少为1颗星)";
    }
    return _alertLabel;
}

- (UIView *)spliterline {
    if (!_spliterline) {
        _spliterline = [[UIView alloc] init];
        _spliterline.backgroundColor = [UIColor colorFromHexString:@"#2f74bb"];
    }
    return _spliterline;
}

- (UIView *)spliterMidLine {
    if (!_spliterMidLine) {
        _spliterMidLine = [[UIView alloc] init];
        _spliterMidLine.backgroundColor = [UIColor colorFromHexString:@"2f74bb"];
    }
    return _spliterMidLine;
}

- (void)layoutSubviews {
    [self initSubViews];
    [super layoutSubviews];
}

- (void) initSubViews {
//    [self.topCircleView addSubview:self.titleLabel];
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.topCircleView).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
//    }];
////    self.titleLabel.text = self.title;
//    self.titleLabel.textColor = WhiteColor;
//    self.titleLabel.font = [UIFont systemFontOfSize:kTextFont];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.containerView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView.mas_left).with.offset(15);
        make.top.mas_equalTo(self.spliter.mas_bottom).with.offset(CriterionSpace);
        make.width.mas_equalTo(self.messageLabel.mas_width);
        make.height.mas_equalTo(self.messageLabel.mas_height);
    }];
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.font = [UIFont systemFontOfSize:kTextFont];
    self.messageLabel.numberOfLines = 3;
    
    [self.containerView addSubview:self.alertLabel];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageLabel.mas_right).with.offset(5);
        make.bottom.mas_equalTo(self.messageLabel.mas_bottom).with.offset(-2);
    }];
    
    [self.containerView addSubview:self.starRatingView];
    
    [self.containerView addSubview:self.spliterline];
    [self.spliterline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.top.mas_equalTo(self.containerView.mas_top).with.offset(CGRectGetHeight(self.frame) / 3 * 2);
        make.height.mas_equalTo(1.5);
    }];
    
    [self.containerView addSubview:self.spliterMidLine];
    [self.spliterMidLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.spliterline.mas_bottom);
        make.centerX.mas_equalTo(self.containerView.mas_centerX);
        make.width.mas_equalTo(1);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
    }];
    
    [self.containerView addSubview:self.buttonContainer];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.top.mas_equalTo(self.spliterline.mas_bottom);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
    }];
    
    if(self.buttonTitles) {
        assert(self.buttonTitles.count <= 2 && self.buttonTitles.count > 0);
        
        if(self.buttonTitles.count == 2) {
            NSString* buttonTitle1 = self.buttonTitles[0];
            NSString* buttonTitle2 = self.buttonTitles[1];
            
            UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button1 setTitle:buttonTitle1 forState:UIControlStateNormal];
            [button1 setBackgroundColor:[UIColor clearColor]];
            [button1 setBackgroundImage:[UIColor imageFromHexString:@"#dddddd"] forState:UIControlStateHighlighted];
            [button1 setTitleColor:[UIColor colorFromHexString:@"#7b9bc6"] forState:UIControlStateHighlighted];
            [button1 setTitleColor:[UIColor colorFromHexString:@"#2f74bb"] forState:UIControlStateNormal];
            [button1.titleLabel setFont: [button1.titleLabel.font fontWithSize:17]];
            [button1 setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [self.buttonContainer addSubview:button1];

            [button1 bk_whenTapped:^{
                self.event(self.dialog, 0);
            }];
            
            self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.button2 setTitle:buttonTitle2 forState:UIControlStateNormal];
            [self.buttonContainer addSubview:self.button2];
            self.button2.enabled = NO;
            self.button2.backgroundColor = [UIColor clearColor];
            [self.button2 setTitleColor:[UIColor colorFromHexString:@"#2f74bb"] forState:UIControlStateNormal];
            [self.button2 setBackgroundImage:[UIColor imageFromHexString:@"#dddddd"] forState:UIControlStateHighlighted];
            [self.button2 setTitleColor:[UIColor colorFromHexString:@"#7b9bc6"] forState:UIControlStateHighlighted];
            [self.button2 setTitleColor:[UIColor colorFromHexString:@"#999999"] forState:UIControlStateDisabled];
            [self. button2 bk_whenTapped:^{
                self.event(self.dialog, 1);
            }];
            
//#define STYLE_BUTTON_7(button) \
//[button.titleLabel setFont: [button.titleLabel.font fontWithSize:14]];\
//[button setTitleColor:WhiteColor forState:UIControlStateNormal];\
//[button setBackgroundImage:[UIColor imageFromHexString:@"#47a8ef"] forState:UIControlStateNormal];\
//[button setBackgroundImage:[UIColor imageFromHexString:@"#3883cf"] forState:UIControlStateHighlighted];\
//[button setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];\
//[button.layer setCornerRadius:5.0f];\
//[button.layer setMasksToBounds:YES];

            
            [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.buttonContainer.mas_left);
                make.right.mas_equalTo(self.buttonContainer.mas_centerX).with.offset(-0.5);
                make.top.mas_equalTo(self.buttonContainer.mas_top);
                make.bottom.mas_equalTo(self.buttonContainer.mas_bottom);
            }];
            
            [self.button2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.buttonContainer.mas_centerX).with.offset(0.5);
                make.right.mas_equalTo(self.buttonContainer.mas_right);
                make.top.mas_equalTo(self.buttonContainer.mas_top);
                make.bottom.mas_equalTo(self.buttonContainer.mas_bottom);
            }];
        } else {
            UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button1 bk_whenTapped:^{
                self.event(self.dialog, 0);
            }];
            [button1 setTitle:[self.buttonTitles firstObject] forState:UIControlStateNormal];
            [self.buttonContainer addSubview:button1];
            STYLE_BUTTON_7(button1);
            [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(-30);
                make.leading.mas_equalTo(30);
                make.top.mas_equalTo(self.buttonContainer.mas_top);
                make.height.mas_equalTo(kButtonHeight);
            }];
        }
    }
}

@end

@implementation PNCAlertStarDialog

+ (instancetype)alertWithStarRating:(NSString *)title
                         andMessage:(NSString *)message
               containsButtonTitles:(NSArray *)buttonTitles
               andStarScoreDelegate:(id<StarScoreDelegate>)delegate
               buttonTapEventsBlock:(PNCDialogButtonTapEvent)event {
    return [self alertWithTitle:title
                     andMessage:message
           containsButtonTitles:buttonTitles
                andStarDelegate:delegate
         hideWhenTouchUpOutside:NO
           buttonTapEventsBlock:event];
}

+ (instancetype)alertWithTitle:(NSString*)title
                    andMessage:(NSString*)message
          containsButtonTitles:(NSArray*)buttonTitles
               andStarDelegate:(id<StarScoreDelegate>)delegate
        hideWhenTouchUpOutside:(BOOL)hideWhenTouchUpOutside
          buttonTapEventsBlock:(PNCDialogButtonTapEvent)event {
    
    PNCAlertStarDialog* dialog = [[PNCAlertStarDialog alloc] init];
    dialog.hideWhenTouchUpOutside = hideWhenTouchUpOutside;
    dialog.delegate = delegate;
    
    PNCAlertStarView *starView = [[PNCAlertStarView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
    
    starView.title = title;
    starView.message = message;
    starView.buttonTitles = buttonTitles;
    starView.event = event;
    starView.dialog = dialog;
    starView.starRatingView.delegate = dialog;
    dialog.contentView = starView;
    
    
    return dialog;
}

- (void)starRateView:(PNCStarRatingView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent {
    NSInteger score = newScorePercent * 5;
    PNCAlertStarView* starView = (PNCAlertStarView*)self.contentView;
    starView.button2.enabled = score > 0;

    return [self.delegate starScoreView:starRateView scroePercentDidChange:newScorePercent];
}

@end
