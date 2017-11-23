//
//  PNCAlertDialog.h
//  
//
//  Created by hzpnc on 15/7/8.
//
//

#import "PNCDialog.h"
//#import "PNCDialogView.h" 现在不继承这个了 因为UI不需要上半部分的圆了

@interface PNCDialogViewAlert : UIView

@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* message;
@property (nonatomic, strong) NSArray*  buttonTitles;
@property (copy) PNCDialogButtonTapEvent event;

@property (nonatomic,strong) UILabel*  titleLabel;
@property (nonatomic,strong) UILabel*  messageLabel;

@property (nonatomic,strong) UIView*   buttonContainer;
@property (nonatomic,strong) UIView *spliterline;
@property (nonatomic,strong) UIView *spliterMidLine;

@property (weak) PNCDialog* dialog;

@end


//一个标准的提示对话框，可以显示包括标题，消息，确定和取消对话框

@interface PNCAlertDialog : PNCDialog

+ (instancetype)alertWithTitle:(NSString*)title
                       andMessage:(NSString*)message
             containsButtonTitles:(NSArray*)buttonTitles
                buttonTapEventsBlock:(PNCDialogButtonTapEvent)event;

+ (instancetype)forceAlertWithTitle:(NSString*)title
                    andMessage:(NSString*)message
          containsButtonTitles:(NSArray*)buttonTitles
          buttonTapEventsBlock:(PNCDialogButtonTapEvent)event;

@end
