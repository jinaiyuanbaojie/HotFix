//
//  ZXBUpdateInfo.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/17.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZXBH5UpdateOperation) {
    ZXBH5UpdateOperationIdle,
    ZXBH5UpdateOperationUpdate,
    ZXBH5UpdateOperationRollback
};

@interface ZXBUpdateInfo : NSObject
@property (nonatomic,assign) NSInteger operation;
@property (nonatomic,copy) NSString *downloadUrl;
@property (nonatomic,copy) NSString *updateVersion;
@property (nonatomic,copy) NSString *rollbackVersion;

-(ZXBH5UpdateOperation) matchOperation;
@end
