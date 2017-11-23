//
//  PNCTagDialog.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/8.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCTagDialog.h"
#import "PNCDialogView.h"

@protocol tapBtnDelegate <NSObject>

- (void)tapped:(NSInteger)count;

@end

@interface TagView : UIView

- (instancetype)init;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIButton *rightDownBtn;
@property (nonatomic,strong) UIView * buttonContainer;
@property (nonatomic,weak) id<tapBtnDelegate> delegate;
@end

@implementation TagView

- (instancetype)init {
    if (self = [super init]) {
        self.backView = [[UIView alloc] init];
        self.rightDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightDownBtn setBackgroundImage:[UIImage imageNamed:@"tag_color_pick"] forState:UIControlStateNormal];
        [self.rightDownBtn setBackgroundImage:[UIImage imageNamed:@"tag_color_picked"] forState:UIControlStateSelected];
        self.rightDownBtn.layer.cornerRadius = 7.0;
        self.rightDownBtn.layer.masksToBounds = YES;
        [self addSubview:self.backView];
        [self addSubview:self.rightDownBtn];
    
        [self bk_whenTapped:^{
            [self.delegate tapped:self.tag];
        }];
        }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right).with.offset(-7 * ADJUSTWIDTH);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(-7 * ADJUSTWIDTH);
    }];
    
    [self.rightDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView.mas_right).with.offset(-7* ADJUSTWIDTH);
        make.top.mas_equalTo(self.backView.mas_bottom).with.offset(-7* ADJUSTWIDTH);
        make.height.mas_equalTo(14 * ADJUSTWIDTH);
        make.width.mas_equalTo(14 * ADJUSTWIDTH);
    }];
}

@end

@interface PNCTagDialogView : PNCDialogView

@property (nonatomic,strong) UILabel *colorPickLabel;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) TagView *tagView;
@property (nonatomic,strong) UILabel *tagNameLebel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSArray*  buttonTitles;
@property (nonatomic,copy) PNCDialogTagChooseBlock block;
@property (nonatomic,weak) PNCDialog *dialog;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) UIButton* button;
@end

@implementation PNCTagDialogView

- (void)tapped:(NSInteger)count{
    for (UIView *view in self.containerView.subviews) {
        if ([view.class isSubclassOfClass:[TagView class]]) {
            TagView* v = (TagView*)view;
            v.rightDownBtn.selected = NO;
            if (v.tag == count) {
                v.rightDownBtn.selected = YES;
            }
        }
    }
    self.count = count;
}

- (instancetype)initWithFrame:(CGRect)frame WithInitColor:(NSString *)color{
    if (self = [super initWithFrame:frame]) {
        self.colorPickLabel = [UILabel new];
        self.colorPickLabel.text = @"颜色选择";
        [self.containerView addSubview:self.colorPickLabel];
        [self.colorPickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).with.offset(10);
            make.left.mas_equalTo(self.mas_left).with.offset(20);
            make.height.mas_equalTo(self.colorPickLabel);
            make.width.mas_equalTo(self.colorPickLabel);
        }];
        
        
        self.imgView = [UIImageView new];
        self.imgView.image = [UIImage imageNamed:@"alert_shut_down"];
        self.imgView.userInteractionEnabled = YES;
        self.imgView.contentMode = UIViewContentModeCenter;
        [self.imgView bk_whenTapped:^{
            self.block(self.dialog,nil,nil,0);
        }];
        [self.containerView addSubview:self.imgView];
        [self.imgView  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.right.mas_equalTo(self.mas_right);
            make.height.mas_equalTo(33);
            make.width.mas_equalTo(33);
        }];
        
        
        NSArray *array = @[COLOR_0,COLOR_1,COLOR_2,COLOR_3,COLOR_4];
        for (int i = 0; i < 5; i++) {
            self.tagView = [[TagView alloc] init];;
            self.tagView.tag = i;
            self.tagView.delegate = (id)self;                    
            if (color != nil) {
                if ([color isEqualToString:array[i]]) {
                    self.tagView.rightDownBtn.selected = YES;
                }
            }
            self.tagView.backView.backgroundColor = [UIColor colorFromHexString:array[i]];
            [self.containerView addSubview:self.tagView];
            [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.colorPickLabel.mas_bottom).with.offset(10);
                make.left.mas_equalTo(self.mas_left).with.offset(20 + i * 60 * ADJUSTWIDTH);
                make.width.mas_equalTo(45 * ADJUSTWIDTH);
                make.height.mas_equalTo(35 * ADJUSTWIDTH);
            }];
        }
        
        self.tagNameLebel = [UILabel new];
        self.tagNameLebel.text = @"标签名称";
        [self.containerView addSubview:self.tagNameLebel];
        [self.tagNameLebel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tagView.mas_bottom).with.offset(5);
            make.left.mas_equalTo(self.colorPickLabel.mas_left);
            make.height.mas_equalTo(self.tagNameLebel);
            make.width.mas_equalTo(self.tagNameLebel);
        }];
        
        self.textField = [UITextField new];
        self.textField.text = @"课堂笔记";
        self.textField.font = [UIFont systemFontOfSize:14];
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.layer.borderWidth = 1.0;
        self.textField.layer.cornerRadius = 5.0;
        self.textField.placeholder = @"最多输入6位";
        self.textField.layer.borderColor = GrayColor.CGColor;
        self.textField.layer.masksToBounds = YES;
        [self.containerView addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tagNameLebel);
            make.right.mas_equalTo(self.mas_right).with.offset(-20);
            make.top.mas_equalTo(self.tagNameLebel.mas_bottom).with.offset(8);
            make.height.mas_equalTo(30);
        }];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button bk_whenTapped:^{
            self.block(self.dialog,array[self.count],self.textField.text,1);
        }];
        [_button setEnabled:NO];
        [_button setTitle:[self.buttonTitles firstObject] forState:UIControlStateNormal];
        [_button.titleLabel setFont: [_button.titleLabel.font fontWithSize:14]];
        _button.layer.cornerRadius = 5;
        [_button setTitle:@"确定" forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIColor imageFromHexString:@"#EEEEEE"] forState:UIControlStateDisabled];
        _button.layer.masksToBounds = YES;
        [_button setTitleColor:[UIColor colorFromHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor colorFromHexString:@"#ffffff"] forState:UIControlStateHighlighted];
        [_button setBackgroundImage:[UIColor imageFromHexString:@"#ff3333"] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIColor imageFromHexString:@"#800000"] forState:UIControlStateHighlighted];
        [_button setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.containerView addSubview:_button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textField.mas_bottom).with.offset(15);
            make.left.mas_equalTo(self.textField.mas_left);
            make.right.mas_equalTo(self.textField.mas_right);
            make.height.mas_equalTo(30);
        }];
        
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.textField) {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
        if (textField.text.length == 0) {
            [_button setEnabled:NO];
        } else {
            [_button setEnabled:YES];
        }
    }
}

@end

@implementation PNCTagDialog

+ (instancetype)inputWithTitle:(NSString *)title
            andInitPickedColor:(NSString *)color andCommitBlock:(PNCDialogTagChooseBlock)block {

    PNCTagDialog* dialog = [[PNCTagDialog alloc] init];
    
    PNCTagDialogView *tagDialogView = [[PNCTagDialogView alloc] initWithFrame:CGRectMake(0, 0, 320 * ADJUSTWIDTH, 280)WithInitColor:color];
    dialog.hideWhenTouchUpOutside = NO;
    tagDialogView.textField.text = title;
    tagDialogView.block = block;
    tagDialogView.dialog = dialog;
    dialog.contentView = tagDialogView;
    
    return dialog;
}

@end

