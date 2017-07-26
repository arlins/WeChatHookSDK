//
//  WXHookQueryTaskMgr.m
//  555
//
//  Created by dps on 17/3/14.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoQueryTaskMgr.h"
#import "HKAsynTickoutTask.h"
#import "WXHongBaoOpeartionMgr.h"
#import "WXHongBaoMessageListMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "HKCommonDefine.h"
#import "WeChatCommonDefine.h"
#import "WXHongBaoSettingMgr.h"

@interface WXHongBaoQueryTaskMgr ()

@property (nonatomic, strong) NSMutableArray<HKAsynTickoutTask *> *taskList;

@end

@implementation WXHongBaoQueryTaskMgr

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.taskList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (HKAsynTickoutTask *)taskByName:(NSString *)name
{
    for ( HKAsynTickoutTask *task in self.taskList )
    {
        if ( [task.name isEqualToString:name] )
        {
            return task;
        }
    }
    
    return nil;
}

- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap
{
    NSString *sendId = [[WXHongBaoMessageListMgr shareInstance] sendIdFromMessage:wrap];
    HKAsynTickoutTask *task = [self taskByName:sendId];
    if ( task != nil )
    {
        return;
    }
    
    HKTagNSLog(KWeChatHookSDKLog, @"查询领取详情");
    if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"查询领取详情"];
    }
    
    HKAsynTicktockTaskBlock taskBlock = ^(HKAsynTickoutTask *task){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *msgType = [NSString stringWithFormat:@"%d", task.repeatCount];
        NSString *fixNativeURL = nil;
    
        fixNativeURL = [NSString stringWithFormat:@"weixin://weixinhongbao/opendetail?sendid=%@", sendId];
        
        [params setObject:msgType forKey:@"msgType"];
        [params setObject:sendId forKey:@"sendId"];
        [params setObject:fixNativeURL forKey:@"nativeUrl"];
        
        [[WXHongBaoOpeartionMgr shareInstance] wxQueryRedEnvelopesDetailRequest:params];
    };
    
    HKAsynTickoutTask* newTask = [[HKAsynTickoutTask alloc] init];
    newTask.name = sendId;
    newTask.duration = [[WXHongBaoSettingMgr shareInstance] queryDelay];
    newTask.taskBlock = taskBlock;
    newTask.userInfo = wrap;
    newTask.repeat = YES;
    
    [newTask start];
    [self.taskList addObject:newTask];
}

- (void)stopQueryHongBaoDetailTask:(CMessageWrap *)wrap
{
    NSString *sendId = [[WXHongBaoMessageListMgr shareInstance] sendIdFromMessage:wrap];
    HKAsynTickoutTask *task = [self taskByName:sendId];
    if ( task == nil )
    {
        return;
    }
    
    HKTagNSLog(KWeChatHookSDKLog, @"停止查询领取详情");
    if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"停止查询领取详情"];
    }
    
    [task stop];
    [self.taskList removeObject:task];
}

- (BOOL)isRunningQueryTaskOf:(CMessageWrap *)wrap
{
    NSString *sendId = [[WXHongBaoMessageListMgr shareInstance] sendIdFromMessage:wrap];
    HKAsynTickoutTask *task = [self taskByName:sendId];
    
    return task != nil;
}

- (void)startQueryHongBaoStateTask:(NSString *)nativeURL
{
    NSString *sendId = [[WXHongBaoMessageListMgr shareInstance] sendIdFromNativeURL:nativeURL];
    NSString *name = [self nameOfQueryState:nativeURL];
    HKAsynTickoutTask *task = [self taskByName:name];
    if ( task != nil )
    {
        return;
    }
    
    NSString* log = [NSString stringWithFormat:@"自动查询红包状态 name = %@", name];
    HKTagNSLog(KWeChatHookSDKLog, log);
    if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"自动查询红包状态"];
    }
    
    HKAsynTicktockTaskBlock taskBlock = ^(HKAsynTickoutTask *task){
        //查询红包
        NSString *fixNativeURL = [NSString stringWithFormat:@"weixin://weixinhongbao/opendetail?sendid=%@", sendId];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"1" forKey:@"msgType"];
        [params setObject:sendId forKey:@"sendId"];
        [params setObject:fixNativeURL forKey:@"nativeUrl"];
        
        [[WXHongBaoOpeartionMgr shareInstance] openHongBaoByNativeURL:nativeURL usingCacheTimingId:NO log:NO];
    };
    
    HKAsynTickoutTask* newTask = [[HKAsynTickoutTask alloc] init];
    newTask.name = name;
    newTask.duration = 0;
    newTask.taskBlock = taskBlock;
    newTask.userInfo = nativeURL;
    newTask.repeat = NO;
    
    [newTask start];
    [self.taskList addObject:newTask];
}

- (void)stopQueryHongBaoStateTask:(NSString *)nativeURL
{
    NSString *name = [self nameOfQueryState:nativeURL];
    HKAsynTickoutTask *task = [self taskByName:name];
    
    NSString *log = [NSString stringWithFormat:@"停止查询红包状态 task = %d, name = %@", task != nil, name];
    HKTagNSLog(KWeChatHookSDKLog, log);
    
    if ( task == nil )
    {
        return;
    }
    
    if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"停止查询红包状态"];
    }
    
    [task stop];
    [self.taskList removeObject:task];
}

- (BOOL)isRunningQueryStateTaskOf:(NSString *)nativeURL
{
    NSString *name = [self nameOfQueryState:nativeURL];
    HKAsynTickoutTask *task = [self taskByName:name];
    
    return task != nil;
}

- (NSString *)nameOfQueryState:(NSString *)nativeURL
{
    NSString *sendId = [[WXHongBaoMessageListMgr shareInstance] sendIdFromNativeURL:nativeURL];
    return [NSString stringWithFormat:@"querystate_%@", sendId];
}

@end
