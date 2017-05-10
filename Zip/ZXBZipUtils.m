//
//  ZXBZipUtils.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/10.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ZXBZipUtils.h"
#import "ZipArchive.h"

@implementation ZXBZipUtils
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination{
    return [SSZipArchive unzipFileAtPath:path toDestination:destination];
}

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite{
    return [self unzipFileAtPath:path toDestination:destination overwrite:overwrite password:nil error:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError**)error{    
    return [SSZipArchive unzipFileAtPath:path toDestination:destination overwrite:overwrite password:password error:error];
}

@end
