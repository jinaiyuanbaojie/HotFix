//
//  ZXBH5UpdateManager.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/12.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpdateCompleteHandler)(NSString *loadVersion);

@interface ZXBH5UpdateManager : NSObject
+(void) updateModule:(NSString*) module completeHandler:(UpdateCompleteHandler) handler;
@end

/**
-异常逻辑：
 控制请求间隔，防止统一时刻多次下载和请求统一模块
 app升级 重制数据库信息 reset
 解压失败
 失败了是一天后请求 还是下次进入继续请求？
 NSBundle每次安装都会覆盖旧的资源，不会保留之
 iCloud云同步数据库和下载zip 会不会干扰代码逻辑？
 
 
-业务：
 新增模块如何最小代价集成到现有的更新逻辑
 并发控制
 线程安全
 
-兜底方案：
 回退到安装包H5版本
 
*/
