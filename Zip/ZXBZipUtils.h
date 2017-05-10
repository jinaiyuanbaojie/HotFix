//
//  ZXBZipUtils.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/10.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXBZipUtils : NSObject
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;

/**
 * @param overwrite yes 表示合并
 */
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite;
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError**)error;
@end
