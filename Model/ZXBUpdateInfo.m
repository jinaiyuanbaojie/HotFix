//
//  ZXBUpdateInfo.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/17.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ZXBUpdateInfo.h"

@implementation ZXBUpdateInfo
-(ZXBH5UpdateOperation) matchOperation{
    ZXBH5UpdateOperation operation = ZXBH5UpdateOperationIdle;
    
    switch (_operation) {
        case 0:
            operation = ZXBH5UpdateOperationIdle;
            break;
        case 1:
            operation = ZXBH5UpdateOperationUpdate;
            break;
        case 2:
            operation = ZXBH5UpdateOperationRollback;
            break;
        default:
            break;
    }
    
    return operation;
}
@end
