//
//  PNCDropdownMenu.h
//
//  Version:1.0.0
//
//  Created by MajorLi on 15/5/4.
//  Copyright (c) 2015年 iOS开发者公会. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "DropdownMuneTableViewCell.h"
#import "TagEditTwoView.h"
@class PNCDropdownMenu;


//typedef NS_ENUM(NSUInteger, AudioQueueState) {
//    AudioQueueState_Idle,
//    AudioQueueState_Recording,
//    AudioQueueState_Playing,
//};

typedef NS_ENUM(NSUInteger,DropDownType) {
    Type_alert = 0,
    Type_record_file = 1,
};

@protocol PNCDropdownMenuDelegate <NSObject>

@optional

- (void)dropdownMenuWillShow:(PNCDropdownMenu *)menu;    // 当下拉菜单将要显示时调用
- (void)dropdownMenuDidShow:(PNCDropdownMenu *)menu;     // 当下拉菜单已经显示时调用
- (void)dropdownMenuWillHidden:(PNCDropdownMenu *)menu;  // 当下拉菜单将要收起时调用
- (void)dropdownMenuDidHidden:(PNCDropdownMenu *)menu;   // 当下拉菜单已经收起时调用

- (void)dropdownMenu:(PNCDropdownMenu *)menu selectedCellNumber:(NSInteger)number; // 当选择某个选项时调用

@end

@interface PNCDropdownMenu : UIView <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView * _arrowMark;   // 尖头图标
//    UIView      * _listView;    // 下拉列表背景View
    
    NSArray     * _titleArr;    // 选项数组
    NSArray     * _colorArr;    // 颜色数组
    CGFloat       _rowHeight;   // 下拉列表行高
}

@property (nonatomic,strong) UIView *listView;


@property (nonatomic,strong) UIButton * mainBtn;  // 主按钮 可以自定义样式 可在.m文件中修改默认的一些属性

@property (nonatomic, assign) id <PNCDropdownMenuDelegate>delegate;

@property (nonatomic,assign) DropDownType type;

@property (nonatomic,strong) NSMutableArray *numberArr;

@property (nonatomic,strong)     UITableView * tableView;   // 下拉列表

@property (nonatomic,strong)  TagEditTwoView *footView;

- (void)setMenuTitles:(NSArray *)titlesArr titleColors:(NSArray *)colorsArr rowHeight:(CGFloat)rowHeight;  // 设置下拉菜单控件样式

- (void)setMenuTitles:(NSArray *)titlesArr titleColors:(NSArray *)colorsArr rowHeight:(CGFloat)rowHeight andNumberArray:(NSMutableArray*)array;
- (void)showDropDown; // 显示下拉菜单
- (void)hideDropDown; // 隐藏下拉菜单

@end
