//
//  ZXBH5UpdateManager.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/12.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ZXBH5UpdateManager.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "ZXBH5UpdateRequester.h"
#import "ZXBH5ModuleVersion.h"
#import "ZXBUpdateInfo.h"
#import "ZXBFileDownloader.h"
#import "ZXBZipUtils.h"

static NSString *const Platform = @"iOS";
static const double kUpdateTimeInterval = 24*60*60; //一天
static NSString *const kLastZXWAppVersion = @"zxb_app_version_recoder_for_h5Update";
static NSString *const kDefaultH5UpdateVersion = @"0";
static NSString *const kZXBUpdateMoudlePlist = @"zxb_h5update_config";

@interface ZXBH5UpdateManager()
@property (nonatomic,strong) ZXBH5UpdateRequester *requester;
@property (nonatomic,copy) NSMutableDictionary<NSString*,ZXBH5ModuleVersion*> *updateVersionDic;
@property (nonatomic,copy,readonly) NSDictionary<NSString*,NSString*> *updateConfig;

//TODO:记录是否正在加载更新资源，防止重复请求
@property (nonatomic,copy) NSMutableDictionary<NSString*,NSNumber*> *loadingDic;
@end

@implementation ZXBH5UpdateManager

+ (instancetype)sharedInstance{
    static id sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    
    return sharedManager;
}

-(instancetype) init{
    self = [super init];
    
    if (self) {
        [ZXBH5ModuleVersion createTable];
        NSArray<ZXBH5ModuleVersion*> *ret = [self qureyAllH5ModuleInfo];
        
        _updateVersionDic = [[NSMutableDictionary alloc] initWithCapacity:ret.count];
        [ret enumerateObjectsUsingBlock:^(ZXBH5ModuleVersion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_updateVersionDic setValue:obj forKey:obj.updateModuleId];
        }];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:kZXBUpdateMoudlePlist ofType:@"plist"];
        _updateConfig = [[NSDictionary alloc] initWithContentsOfFile:path];

        _loadingDic = [NSMutableDictionary new];
        _requester = [ZXBH5UpdateRequester new];
    }
    
    return self;
}

-(NSArray<ZXBH5ModuleVersion*>*) qureyAllH5ModuleInfo{
    NSArray<ZXBH5ModuleVersion*> *ret = [ZXBH5ModuleVersion queryAll];
    
    //app版本更新，把h5更新的版本号重置为0
    if ([self isAppUpdate]) {
        [ret enumerateObjectsUsingBlock:^(ZXBH5ModuleVersion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.lastUpdateVersion = kDefaultH5UpdateVersion;
            obj.timeStamp = [NSDate date].timeIntervalSince1970;
            [obj addOrUpdate];
        }];
    }
    
    return ret;
}

-(BOOL) isAppUpdate{
    NSString *lastAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastZXWAppVersion];
    NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([lastAppVersion isEqualToString:currentAppVersion]) {
        return NO;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kLastZXWAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}

#pragma mark - update

+(void) updateModule:(NSString*) module completeHandler:(UpdateCompleteHandler) handler{
    [[self sharedInstance] updateModule:module completeHandler:handler];
}

-(void) updateModule:(NSString*) module completeHandler:(UpdateCompleteHandler) handler{
    if (!module || !_updateConfig[module]) {
        [self loadAppiontVersion:kDefaultH5UpdateVersion completeHandler:handler];
        return;
    }

    if (![self checkUpdateTimeIntervalWithModule:module]) {
        [self loadLastUpdateVersionWithModule:module writeToDB:NO completeHandler:handler];
        return;
    }
    
    //FIXME:防止短时间内多次请求
    __weak typeof(self) weakSelf = self;
    NSDictionary *param = [self requsetParamWithModule:module];
    [_requester requestWithParam:param completeHandler:^(BOOL isSuccess, ZXBUpdateInfo* ret) {
        if (isSuccess) {
            
            switch ([ret matchOperation]) {
                case ZXBH5UpdateOperationIdle:
                {
                    [weakSelf loadLastUpdateVersionWithModule:module writeToDB:YES completeHandler:handler];
                }
                    break;
                case ZXBH5UpdateOperationUpdate:
                {
                    [weakSelf downloadZipWithUpdateInfo:ret module:module completeHandler:handler];
                }
                    break;
                case ZXBH5UpdateOperationRollback:
                {
                    [weakSelf addUpdateModuleInfoWithModule:module updateVersion:ret.rollbackVersion];
                    [weakSelf loadAppiontVersion:ret.rollbackVersion completeHandler:handler];
                }
                    break;
                default:
                {
                    [weakSelf loadLastUpdateVersionWithModule:module writeToDB:YES completeHandler:handler];
                }
                    break;
            }
            
        }else{
            [weakSelf loadLastUpdateVersionWithModule:module writeToDB:YES completeHandler:handler];
        }
    }];
}

-(BOOL) checkUpdateTimeIntervalWithModule:(NSString*) module{
    ZXBH5ModuleVersion *ret = _updateVersionDic[module];
    NSTimeInterval lastUpdateTime = ret.timeStamp;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    return ((currentTime-lastUpdateTime) > kUpdateTimeInterval);
}

-(void) loadLastUpdateVersionWithModule:(NSString*) module writeToDB:(BOOL) writeToDB completeHandler:(UpdateCompleteHandler) handler{
    NSString *loadVersion = [self lastUpdateVersionWithModule:module];
    
    if (writeToDB) {
        [self addUpdateModuleInfoWithModule:module updateVersion:loadVersion];
    }

    [self loadAppiontVersion:loadVersion completeHandler:handler];
}

-(void) loadAppiontVersion:(NSString*) version completeHandler:(UpdateCompleteHandler) handler{
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(version);
    });
}

-(void) addUpdateModuleInfoWithModule:(NSString*)module updateVersion:(NSString*) version{    
    ZXBH5ModuleVersion *moduleVersion = [ZXBH5ModuleVersion new];
    moduleVersion.updateModuleId = module;
    moduleVersion.lastUpdateVersion = version;
    moduleVersion.timeStamp = [NSDate date].timeIntervalSince1970;
    
    [moduleVersion addOrUpdate];
    [_updateVersionDic setValue:moduleVersion forKey:moduleVersion.updateModuleId];
}

#pragma mark - download

-(void) downloadZipWithUpdateInfo:(ZXBUpdateInfo*) info module:(NSString*) module completeHandler:(UpdateCompleteHandler) handler{
    NSString *zipFilePath = [self downloadZipDestinationPathWithUpdateInfo:info module:module];

    ZXBFileDownloader *downloader = [[ZXBFileDownloader alloc] initWithURL:info.downloadUrl];
    
    __weak typeof(self) weakSelf = self;
    [downloader startDownloadWithProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:zipFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            [weakSelf loadLastUpdateVersionWithModule:module writeToDB:YES completeHandler:handler];
        }else{
            NSString *destinationPath = [weakSelf unZipBundlePathWithModule:module];
            BOOL ret = [ZXBZipUtils unzipFileAtPath:zipFilePath toDestination:destinationPath];
            if (ret) {
                [weakSelf addUpdateModuleInfoWithModule:module updateVersion:info.updateVersion];
                [weakSelf loadAppiontVersion:info.updateVersion completeHandler:handler];
            }else{
                [weakSelf loadLastUpdateVersionWithModule:module writeToDB:YES completeHandler:handler];
            }
        }
    }];
}

-(NSString*) downloadZipDestinationPathWithUpdateInfo:(ZXBUpdateInfo*) info module:(NSString*) module{
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *moduleId = module;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.zip",moduleId,info.updateVersion];
    return [tmpPath stringByAppendingPathComponent:fileName];
}

-(NSString*) unZipBundlePathWithModule:(NSString*) module{
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *modulePath = _updateConfig[module];
    
    return [bundlePath stringByAppendingPathComponent:modulePath];
}

#pragma mark - build_request_param
-(NSDictionary*) requsetParamWithModule:(NSString*)module{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    [dic setValue:Platform forKey:@"systemName"];
    [dic setValue:[[UIDevice currentDevice] systemVersion] forKey:@"systemVersion"];
    [dic setValue:[self machine] forKey:@"machine"];
    [dic setValue:@"AppStore" forKey:@"channel"];
    [dic setValue:[self currentAppVersion] forKey:@"appversion"];
    
    [dic setValue:module forKey:@"moduleId"];
    [dic setValue:[self lastUpdateVersionWithModule:module] forKey:@"lastUpdateVerison"];

    return dic.copy;
}

-(NSString*) lastUpdateVersionWithModule:(NSString*) module{
    ZXBH5ModuleVersion *ret =  _updateVersionDic[module];
    
    if (!ret) {
        return kDefaultH5UpdateVersion;
    }else{
        return ret.lastUpdateVersion;
    }
}

-(NSString*) currentAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

-(NSString*) machine{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding]; //eg. iPhone5
}

@end
