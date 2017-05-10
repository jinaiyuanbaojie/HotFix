//
//  ZXBH5UpdateIRequester.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/17.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZXBUpdateInfo;
typedef void(^RequsetCompleteHandler)(BOOL isSuccess,ZXBUpdateInfo* ret);

@interface ZXBH5UpdateRequester : NSObject
-(void) requestWithParam:(NSDictionary*) param completeHandler:(RequsetCompleteHandler) block;
@end
