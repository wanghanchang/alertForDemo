//
//  PNCAlertDialog.m
//  
//
//  Created by hzpnc on 15/7/8.
//
//

#import "PNCAlertDialog.h"

#define CriterionSpace          16
#define kTextFont               16
#define kMessagePadding         20
#define kButtonHeight           44

@implementation PNCDialogViewAlert

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc] init];
        self.buttonContainer = [[UIView alloc] init];
        self.backgroundColor = WhiteColor;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        return self;
    }
    return nil;
}

- (void)layoutSubviews {
    [self initSubViews];
    [super layoutSubviews];
}

- (UIView *)spliterline {
    if (!_spliterline) {
        _spliterline = [[UIView alloc] init];
        _spliterline.backgroundColor = [UIColor colorFromHexString:@"#33cc66"];
    }
    return _spliterline;
}

- (UIView *)spliterMidLine {
    if (!_spliterMidLine) {
        _spliterMidLine = [[UIView alloc] init];
        _spliterMidLine.backgroundColor = [UIColor colorFromHexString:@"33cc66"];
    }
    return _spliterMidLine;
}


- (void) initSubViews {
//    [self.topCircleView addSubview:self.titleLabel];
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.topCircleView).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
//    }];
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = WhiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:kTextFont];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
//    [self addSubview:self.spliterline];
//    [self.spliterline mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.mas_left);
//        make.right.mas_equalTo(self.mas_right);
//        make.top.mas_equalTo(self.mas_top).with.offset(CGRectGetHeight(self.frame)  - 44);
//        make.height.mas_equalTo(1);
//    }];
    
    UIView *upView = [UIView new];
    [self addSubview:upView];
    [upView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(-66);
    }];
    
    [upView addSubview:self.messageLabel];
   
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = [UIColor colorFromHexString:@"#333333"];
    self.messageLabel.font = [UIFont systemFontOfSize:kTextFont];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(15);
        make.right.mas_equalTo(self.mas_right).with.offset(-15);
        make.height.mas_equalTo(self.messageLabel.mas_height);
        make.centerY.mas_equalTo(upView.mas_centerY);
    }];
    
    
    [self addSubview:self.buttonContainer];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.top.mas_equalTo(upView.mas_bottom);

    }];

    
    if(self.buttonTitles) {
        assert(self.buttonTitles.count <= 2 && self.buttonTitles.count > 0);
        
        if(self.buttonTitles.count == 2) {
            NSString* buttonTitle1 = self.buttonTitles[0];
            NSString* buttonTitle2 = self.buttonTitles[1];
            
            UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button1 setTitle:buttonTitle1 forState:UIControlStateNormal];
            
            button1.backgroundColor = [UIColor clearColor];
            [button1 setBackgroundImage:[UIColor imageFromHexString:@"#fd6a66"] forState:(UIControlStateNormal)];
            [button1 setTitleColor:WhiteColor forState:UIControlStateNormal];

            
            [self.buttonContainer addSubview:button1];
            
            [button1 bk_whenTapped:^{
                self.event(self.dialog, 0);
            }];

            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button2 setTitle:buttonTitle2 forState:UIControlStateNormal];
            [self.buttonContainer addSubview:button2];

            button2.layer.borderWidth = 1;
            button2.layer.borderColor = GrayColor.CGColor;
            [button2 setBackgroundImage:[UIColor imageFromHexString:@"#FFFFFF"] forState:(UIControlStateNormal)];
            [button2 setTitleColor:[UIColor colorFromHexString:@"#999999"] forState:UIControlStateNormal];
            [button2.titleLabel setFont: [button1.titleLabel.font fontWithSize:17]];
            [button2 setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

            [button2 bk_whenTapped:^{
                self.event(self.dialog, 1);
            }];
            
            [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.buttonContainer.mas_left).with.offset(20);
                make.centerY.mas_equalTo(self.buttonContainer.mas_centerY);
                make.right.mas_equalTo(self.buttonContainer.mas_centerX).with.offset(-20);
                make.height.mas_equalTo(33);
            }];
            
            [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.buttonContainer.mas_right).with.offset(-20);
                make.centerY.mas_equalTo(self.buttonContainer);
                make.left.mas_equalTo(self.buttonContainer.mas_centerX).with.offset(20);
                make.height.mas_equalTo(33);
            }];
        } else {
            UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button1 bk_whenTapped:^{
                self.event(self.dialog, 0);
            }];
            [button1 setTitle:[self.buttonTitles firstObject] forState:UIControlStateNormal];
            [button1.titleLabel setFont: [button1.titleLabel.font fontWithSize:14]];
            button1.backgroundColor = [UIColor clearColor];
            [button1 setBackgroundImage:[UIColor imageFromHexString:@"#fd6a66"] forState:(UIControlStateNormal)];
            [button1 setTitleColor:WhiteColor forState:UIControlStateNormal];
            [button1 setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [self.buttonContainer addSubview:button1];
            [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(self.buttonContainer);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(44);
            }];
        }
    }
}

@end

@implementation PNCAlertDialog

+(instancetype)alertWithTitle:(NSString *)title
                   andMessage:(NSString *)message
         containsButtonTitles:(NSArray *)buttonTitles
         buttonTapEventsBlock:(PNCDialogButtonTapEvent)event {
    return [PNCAlertDialog alertWithTitle:title
                               andMessage:message
                     containsButtonTitles:buttonTitles
                   hideWhenTouchUpOutside:YES
                     buttonTapEventsBlock:event];
}

+ (instancetype)forceAlertWithTitle:(NSString*)title
                         andMessage:(NSString*)message
               containsButtonTitles:(NSArray*)buttonTitles
               buttonTapEventsBlock:(PNCDialogButtonTapEvent)event {
    return [PNCAlertDialog alertWithTitle:title
                        andMessage:message
              containsButtonTitles:buttonTitles
            hideWhenTouchUpOutside:NO
              buttonTapEventsBlock:event];
}

+ (instancetype)alertWithTitle:(NSString*)title
                    andMessage:(NSString*)message
          containsButtonTitles:(NSArray*)buttonTitles
        hideWhenTouchUpOutside:(BOOL)hideWhenTouchUpOutside
          buttonTapEventsBlock:(PNCDialogButtonTapEvent)event {
    
    PNCAlertDialog* dialog = [[PNCAlertDialog alloc] init];
    dialog.hideWhenTouchUpOutside = hideWhenTouchUpOutside;
    //CGRectMake(0.5 * (screenSize.width - contentSize.width), 0.5 * (screenSize.height - contentSize.height),
//    contentSize.width, contentSize.height / 3)
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    
    CGSize retSize = [message boundingRectWithSize:CGSizeMake(250, 0)
                                          options:\
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
    CGFloat num = retSize.height > 60 ? retSize.height + 150 : 200;
    
    PNCDialogViewAlert* view = [[PNCDialogViewAlert alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH * 0.8, num)];
    view.title = title;
    view.message = message;
    view.buttonTitles = buttonTitles;
    view.event = event;
    view.dialog = dialog;
    
    dialog.contentView = view;
    
    return dialog;
}

@end
