//
//  ZXBH5UpdateIRequester.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/4/17.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ZXBH5UpdateRequester.h"
#import "ZXBUpdateInfo.h"

@implementation ZXBH5UpdateRequester

-(void) requestWithParam:(NSDictionary*) param completeHandler:(RequsetCompleteHandler) block{
    ZXBUpdateInfo *info = [ZXBUpdateInfo new];
    info.operation = 1;
    info.updateVersion = @"1.1";
    
    //百度云盘的url
    info.downloadUrl = @"https://nj01ct01.baidupcs.com/file/3807a1bdcb1bcd94ab2cece0eed13c09?bkt=p3-14003807a1bdcb1bcd94ab2cece0eed13c09cedd2e0700000001e3a8&fid=623717441-250528-639019413304356&time=1492655323&sign=FDTAXGERLBHS-DCb740ccc5511e5e8fedcff06b081203-Ekfi9P1l%2FVdKBku%2FywB2d7jlrO4%3D&to=63&size=123816&sta_dx=123816&sta_cs=3&sta_ft=zip&sta_ct=0&sta_mt=0&fm2=MH,Yangquan,Netizen-anywhere,,tianjin,ct&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=14003807a1bdcb1bcd94ab2cece0eed13c09cedd2e0700000001e3a8&sl=83034191&expires=8h&rt=sh&r=559467362&mlogid=2538144032762624347&vuk=623717441&vbdid=2399561397&fin=Payment_1.1.zip&rtype=1&iv=0&dp-logid=2538144032762624347&dp-callid=0.1.1&hps=1&csl=300&csign=TF3JtNk1K7eIgpEfO4qRwInLUnE%3D&by=themis";
    
    block(YES,info);
}

- (NSString *)findBaseUrl:(int)requestType{
    return @"http://app.zhixue.com/....";
}

- (id)parse:(id)result requestType:(int)requestType{
    return result; //transform to ZXBUpdateInfo
}

@end
