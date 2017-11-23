//
//  RecordFileEditInfoAlert.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/11.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNCDropdownMenu.h"

@class RecordFileEditInfoAlert;
@class TagAlertObj;
typedef  void(^RecordFileEditInfoAlertBlock)(RecordFileEditInfoAlert *myAlert, int buttonindex, TagAlertObj *obj);

@interface RecordFileEditInfoAlert : UIView <PNCDropdownMenuDelegate>

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) UILabel *tagNameLabel;
@property (nonatomic,strong) UILabel *recordNameLabel;
@property (nonatomic,strong) UIView *roundUpDot;
@property (nonatomic,strong) UITextField *recordNameTextField;

@property (nonatomic,strong) UILabel *belongLabel;
@property (nonatomic,strong) UIView *roundDownDot;
@property (nonatomic,strong) PNCDropdownMenu *menu;

@property (nonatomic,strong) UIView*   buttonContainer;
@property (nonatomic,assign) NSInteger count;

@property (nonatomic,strong) NSMutableArray *dateArray;
@property (nonatomic,assign) NSInteger arrayIndex;


@property (nonatomic,strong) UIView *myBackView;

- (instancetype)initWithFrame:(CGRect)frame WithCancelName:(NSString*)cancelName WithObj:(TagAlertObj*)obj WithBlock:(RecordFileEditInfoAlertBlock)block;
- (void)hide;
- (void)show;


@end

@interface TagAlertObj : NSObject
@property (nonatomic,copy) NSString *recordName;
@property (nonatomic,copy) NSString *tagName;
@property (nonatomic,copy) NSString *tagColor;
@end
