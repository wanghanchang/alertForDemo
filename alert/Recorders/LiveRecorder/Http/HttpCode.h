//
//  HttpCode.h
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/7/21.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#ifndef HttpCode_h
#define HttpCode_h

#define  HTTP_OK                    0               //正常返回
#define  PARAM_BLANK                10001       //参数为空
#define  SESSION_EXPIRED            20001		//session过期
#define  LOG_OUT_COMPELLENT         20006       //用户被强制登出
#define  REDIS_FAULT                50001			//redis服务器错误（服务器内部错误）
#define  DB_ERROR                   50002          //Mysql数据库错误（服务器内部错误）
#define THIRD_ERROR                 50003           //第三方对接出错

#define  UN_REGISTER                20002       //用户未注册
#define OLD_USER                    20003	//老用户
#define  VERIFY_CODE_INVALIDATE     20004			//验证码已经失效
#define  VERIFY_CODE_TOO_FAST       20005			//验证码已经失效
#define LOG_OUT_A                   20006
#define LOG_OUT_B                   20009     ///

#define THIRD_PATH_BINDED           20007       //已经绑定三方
#define AUTH_EXPIRED                20008       //授权过期
#define AUTH_ERROR                  20009       //授权出错
#define THIRD_PATH_UN_BINDED        20010	//未绑定三方	number
#define QINIU_VALIDATE_ERROR        30001	//七牛回调验证出错
#define FILE_INVALIDATE             30002	//文件已经失效
#define ORDER_UN_EXSIST             40001	//订单不存在
#define ORDER_PAYED                 40002	//订单已支付
#define ORDER_UN_FINISED            40003	//	有正在进行的未完成订单


#define PAY_BAD                     99999
#define UPLOAD_BAD                  99998
#define  NO_NET                     99997
#define ERR_IPA                     99996


#endif /* HttpCode_h */


