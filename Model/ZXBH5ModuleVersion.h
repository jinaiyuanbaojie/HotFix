//
//  ZXBH5ModuleVersion.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/17.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORMObject.h"

@interface ZXBH5ModuleVersion : ORMObject
@property(nonatomic,copy) NSString *updateModuleId;
@property(nonatomic,copy) NSString *lastUpdateVersion;
@property(nonatomic,assign) double timeStamp;
@end
