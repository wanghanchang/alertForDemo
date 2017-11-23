//
//  RecordFileViewController.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/26.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "RecordFileViewController.h"
#import "RecordFileTableViewCell.h"
#import "LiveRecordHelper.h"
#import "PlayViewController.h"
#import "UpLoadTranslate.h"
#import "AES.h"
#import "RecordFileEditInfoAlert.h"
#import "WechatQQRequest.h"
#import "OrdersRequest.h"
#import "NSString+Trim.h"
#import "NSString+AESSecurity.h"
#import "MD5Relevant.h"
#import "PNCShareDialog.h"
#import "RecordUploadOrShare.h"

#import "PNCDropdownMenu.h"

#import "OrderStateViewController.h"


#import "TagEditController.h"
@interface RecordFileViewController ()<UITableViewDelegate,UITableViewDataSource,PNCDropdownMenuDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *array;
@property (nonatomic,strong) UIView *topLine;
@property (nonatomic,strong) PNCDropdownMenu * dropdownMenu;


//标签颜色 标签名称 标签文件个数的数组
@property (nonatomic,strong) NSMutableArray *colorArr;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *numberArray;

@property (nonatomic,assign) NSInteger currentNumber;
@property (nonatomic,strong) UIView *grayBack;

@end

@implementation RecordFileViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    [[self.dropdownMenu subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.dropdownMenu.listView removeFromSuperview];
    [self.dropdownMenu removeFromSuperview];
    
    if (self.grayBack) {
        [self.grayBack removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=NO;
    self.navigationController.navigationBar.hidden = YES;
    LiveRecordHelper *helper = [LiveRecordHelper helper];
    self.array = [NSMutableArray arrayWithArray:[helper listAllDesc]];
    
    [self.tableView reloadData];
    
    _dropdownMenu = [[PNCDropdownMenu alloc] init];
    _dropdownMenu.type = Type_record_file;
    _dropdownMenu.frame= CGRectMake(0 , 27, SCREENWIDTH , 30);
    _dropdownMenu.delegate = self;
    
    NSString *path = [CommonUtils generateFilePathWithUserFileName:COLOR_SETTING andFileManagerName:[[AccountInfo shareInfo] mobile]];
    NSDictionary *dic = [CommonUtils getJsonDataToDicByPath:path];
        
    if (dic == NULL) {
        _dataArray = [NSMutableArray arrayWithObjects:@"全部",@"未分组", nil];
        _colorArr = [NSMutableArray arrayWithObjects:@"#333333" ,COLOR_0, nil];
    } else {
        _dataArray = [NSMutableArray arrayWithArray:[dic allKeys]];
        _colorArr = [NSMutableArray arrayWithArray:[dic allValues]];
        [_dataArray insertObject:@"全部" atIndex:0];
        [_dataArray insertObject:@"未分组" atIndex:1];
        [_colorArr insertObject:@"#333333" atIndex:0];
        [_colorArr insertObject:COLOR_0 atIndex:1];
    }
    [self getEveryNumber];
    [_dropdownMenu setMenuTitles:_dataArray titleColors:_colorArr rowHeight:40 * ADJUSTHEIGHT];
    [self.view addSubview:_dropdownMenu];
    
    _currentNumber = -1;
    
//    [self checkEvertyFileNumer];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.array.count-1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    self.dropdownMenu.footView.userInteractionEnabled = YES;
    [self.dropdownMenu.footView bk_whenTapped:^{
        TagEditController  *v= [[TagEditController alloc] init];
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:v animated:YES];
    }];

}

- (void)getEveryNumber {
    LiveRecordHelper *helper = [LiveRecordHelper helper];
    [self runInGlobalQueue:^{
        self.numberArray = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < self.dataArray.count; i++) {
            if (i == 0) {
                [self.numberArray addObject:[NSString stringWithFormat:@"%ld",[[helper listAllDesc] count]]];
            } else if (i == 1) {
                [self.numberArray addObject:[NSString stringWithFormat:@"%ld",[[helper listByNoArrayData:self.dataArray] count]]];
            } else {
                [self.numberArray addObject:[NSString stringWithFormat:@"%ld",[[helper listByRecordTag:[_dataArray objectAtIndex:i]] count]]];
            }
        }
        [self runInMainQueue:^{
            _dropdownMenu.numberArr = _numberArray;
            [_dropdownMenu.tableView reloadData];
        }];
    }];
    
}

//- (void)scrollViewToBottom:(BOOL)animated {
//    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
//    {
//        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
//        [self.tableView setContentOffset:offset animated:animated];
//    }
//}


#pragma mark - PNCDropdownMenu Delegate

- (void)dropdownMenu:(PNCDropdownMenu *)menu selectedCellNumber:(NSInteger)number{
    _currentNumber = number;
    [self getDataArrayFromPickedNumber:number];
}

- (void)dropdownMenuWillShow:(PNCDropdownMenu *)menu {
    self.grayBack = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    self.grayBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.grayBack.userInteractionEnabled = YES;
    [self.grayBack bk_whenTapped:^{
        [self.grayBack removeFromSuperview];
        [_dropdownMenu hideDropDown];
    }];
    [self.view insertSubview:self.grayBack belowSubview:_dropdownMenu];
}

- (void)dropdownMenuDidHidden:(PNCDropdownMenu *)menu{
    if (self.grayBack) {
        [self.grayBack removeFromSuperview];
    }
}

- (void)dropdownMenuDidShow:(PNCDropdownMenu *)menu {}

- (void)dropdownMenuWillHidden:(PNCDropdownMenu *)menu{}

- (void)getDataArrayFromPickedNumber:(NSInteger)number {
    LiveRecordHelper *helper = [LiveRecordHelper helper];
    if (number == 0) {
        self.array = [NSMutableArray arrayWithArray:[helper listAllDesc]];
    } else if (number == 1) {
        self.array = [NSMutableArray arrayWithArray:[helper listByNoArrayData:self.dataArray]];
    } else {
        self.array = [NSMutableArray arrayWithArray:[helper listByRecordTag:_dataArray[number]]];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"录音文件";
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSForegroundColorAttributeName:[UIColor clearColor]}];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    _topLine.backgroundColor = c_e0e0e0;

    self.tableView.tableHeaderView = _topLine;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(64);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-44);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 140;
}

- (void)translate:(UIButton*)btn {
    UITableViewCell *btnCell = nil;
    btnCell = (UITableViewCell *)btn.superview.superview.superview.superview;
    NSIndexPath *index =   [self.tableView indexPathForCell:btnCell];
    EntityLiveRecord *entity = self.array[index.row];
    OrderStateViewController *os = [[OrderStateViewController alloc] initWithEntity:entity];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:os animated:YES];
}

- (void)share:(ClickImageView*)image {
    
    [[PNCShareDialog initWithPickedBlock:^(PNCDialog *dialog, NSInteger pickedCount,NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [dialog hide];
        } else {
            UITableViewCell *btnCell = nil;
            btnCell = (UITableViewCell *)image.superview.superview.superview.superview;
            NSIndexPath *index =   [self.tableView indexPathForCell:btnCell];
            EntityLiveRecord *entity = self.array[index.row];
            if (entity.isFinishUplaod) {
                [self getShareUrlByFilId:entity withPickedCount:pickedCount];
            } else {
                [self goUplpad:entity withPickedCount:pickedCount];
            }
            [dialog hide];
        }
    }] show];
}

- (void)delete:(ClickImageView*)image {

    [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"确定删除吗?" containsButtonTitles:@[@"确定",@"取消"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
        if (buttonIndex == 0) {
            LiveRecordHelper *helper = [LiveRecordHelper helper];
            UITableViewCell *btnCell = nil;
            btnCell = (UITableViewCell *)image.superview.superview.superview.superview;
            NSIndexPath *index =   [self.tableView indexPathForCell:btnCell];
            EntityLiveRecord *entity = self.array[index.row];
            [helper remove:entity.entityId];
            [CommonUtils delteFilehWithFileName:entity.fileName andFileManagerName:[[AccountInfo shareInfo] mobile]];
            [self.array removeObjectAtIndex:index.row];
            [self.tableView reloadData];
            [self getEveryNumber];
            [dialog hide];
        } else {
            [dialog hide];
        }
    }] show];
}

- (void)edit:(ClickImageView*)image {
    UITableViewCell *btnCell = nil;
    btnCell = (UITableViewCell *)image.superview.superview.superview.superview;
    NSIndexPath *index =   [self.tableView indexPathForCell:btnCell];
    LiveRecordHelper *helper = [LiveRecordHelper helper];
    EntityLiveRecord *entity = self.array[index.row];
    TagAlertObj *obj = [[TagAlertObj alloc] init];
    obj.tagName = entity.recordTag;
    obj.tagColor = entity.recordTagColor;
    obj.recordName = entity.userNamedFile;
    RecordFileEditInfoAlert *alert =  [[RecordFileEditInfoAlert alloc] initWithFrame:CGRectMake(40 * ADJUSTWIDTH , SCREENHEIGHT / 4, (SCREENWIDTH - (80 * ADJUSTWIDTH)), 300 * ADJUSTHEIGHT) WithCancelName:@"取消" WithObj:obj  WithBlock:^(RecordFileEditInfoAlert *myAlert, int buttonindex, TagAlertObj *obj) {
    
                if (buttonindex == 1) {
                    if (obj.recordName.length == 0) {
                        entity.userNamedFile = @"未命名";
                    } else {
                        entity.userNamedFile = obj.recordName;
                    }
    
                    if (entity.recordTag != obj.tagName) {
                        entity.recordTagColor = obj.tagColor;
                        entity.recordTag = obj.tagName;
                        [self getEveryNumber];
                    }
                    [helper updateEntity:entity forEntityId:entity.entityId];
    
                    if (_currentNumber > -1) {
                        [self getDataArrayFromPickedNumber:_currentNumber];
                        [self.tableView reloadData];
                    } else {
                        [self.tableView reloadData];
                    }
                }
                [myAlert hide];
            }];
            [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    RecordFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[RecordFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    EntityLiveRecord *entity = self.array[indexPath.row];
    cell.topCardLabel.backgroundColor = [UIColor colorFromHexString:entity.recordTagColor];
    cell.topCardLabel.text = entity.recordTag;
    cell.nameLabel.text = entity.userNamedFile;
    cell.recordBeginLabel.text = [CommonUtils currentTimeNianYueRiSince1970:entity.startTime];
    cell.recordTimeLabel.text = [CommonUtils translateTimeCount:entity.timeLong];;
    [cell.translateButton setTitle:@"转文字" forState:UIControlStateNormal];
    
    [cell.translateButton addTarget:self action:@selector(translate:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareImg.userInteractionEnabled = YES;
    [cell.shareImg addTarget:self action:@selector(share:) forControlEvent:UIControlEventTouchUpInside];
    
    cell.deleteImg.userInteractionEnabled = YES;
    [cell.deleteImg addTarget:self action:@selector(delete:) forControlEvent:UIControlEventTouchUpInside];
    
    cell.editImg.userInteractionEnabled = YES;
    [cell.editImg addTarget:self action:@selector(edit:) forControlEvent:UIControlEventTouchUpInside];

    return cell;
}


- (void)goUplpad:(EntityLiveRecord *)liveRecord withPickedCount:(Share_Type)pickedCount {
    
    __weak RecordFileViewController *ws = self;
    PNCProgressDialog *dialog = [PNCProgressDialog progressWithTitle:@"" andCommitBlock:^(PNCDialog *dialog) {
        [UpLoadTranslate translate].stop = YES;
        [dialog hide];
    }];
    [dialog show];
    
    RecordUploadOrShare *upload = [[RecordUploadOrShare alloc] init];
    [upload checkUserNetTouploadWithEntity:liveRecord withState:^(UpDateState upState, float progress) {
        PNCProgressViewAlert *progressDialogView = (PNCProgressViewAlert*)dialog.contentView;
        if (upState == Up_ing) {
            [self runInMainQueue:^{
                progressDialogView.progressView.progress = progress;
                progressDialogView.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress * 100];
            }];
        }
        if (upState == Up_done) {
            progressDialogView.label.text = @"已完成";
            [dialog hide];
            [ws getShareUrlByFilId:liveRecord withPickedCount:pickedCount];
        }
        if (upState == Up_fail) {
            [dialog hide];
        }
        
    } WithUserCancel:^(BOOL isCancel) {
        if (isCancel) {
            [dialog hide];
        }
    }];

}

- (void)getShareUrlByFilId:(EntityLiveRecord *)record withPickedCount:(Share_Type)pickedCount {
    __weak RecordFileViewController *ws = self;

    [RecordUploadOrShare goShareWithEntity:record WithReturnKey:^(int a, NSString *shareUrl) {
        if (a == HTTP_OK) {
            if (pickedCount == 4) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = shareUrl;
                UILabel *hintLabel = [[UILabel alloc] init];
                hintLabel.backgroundColor = c_000000;
                hintLabel.alpha = 0.0;
                hintLabel.textAlignment = NSTextAlignmentCenter;
                hintLabel.text = @"已复制链接";
                hintLabel.font = FONT_MEDIUM(14);
                hintLabel.textColor = WhiteColor;
                hintLabel.layer.cornerRadius = 2;
                hintLabel.layer.masksToBounds = YES;
                [self.view addSubview:hintLabel];
                [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view.mas_centerX);
                    make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-44 - 60);
                    make.height.mas_equalTo(hintLabel.mas_height);
                    make.width.mas_equalTo(hintLabel.mas_width);
                }];
                [UIView animateWithDuration:1.0 animations:^{
                    hintLabel.alpha = 0.75;
                } completion:^(BOOL finished){
                    [hintLabel removeFromSuperview];
                }];
                return ;
            }
            if (pickedCount < 2) {
                [WechatQQRequest goWechatShare:pickedCount WithUrl:shareUrl];
                return;
            }
            if (pickedCount == Share_QQ_Zone || pickedCount == Share_QQ_Friend) {
                [WechatQQRequest goQQShare:pickedCount WithUrl:shareUrl];
            }
        }
        
        if (a == FILE_INVALIDATE) {
            [ws goUplpad:record withPickedCount:pickedCount];
        }
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EntityLiveRecord *entity = self.array[indexPath.row];
    PlayViewController *play = [[PlayViewController alloc] initWithFileName:entity];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:play animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
