//
//  HongBaoIPCMgr.m
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import "WXHongBaoIPCCmdMgr.h"
#import <UIKit/UIKit.h>
#import "WeChatHookSDK.h"
#import "WXHongBaoOpeartionMgr.h"
#import "WXHongBaoQueryTaskMgr.h"
#import "HKTCPClient.h"
#import "HKTCPServer.h"
#import "WXHongBaoSettingMgr.h"

NSString *const KWXHongBaoIPCCmdMgrLogArrived = @"KWXHongBaoIPCCmdMgrLogArrived";
NSString *const KWXHongBaoIPCCmdMgrLogKey = @"KWXHongBaoIPCCmdMgrLogKey";
const CGFloat KPasteboardCheckTimerInterval = 0.01;
const NSUInteger KWXHongBaoIPCPort = 9414;

@interface WXHongBaoIPCCmdMgr () <HKTCPClientDelegate, HKTCPServerDelegate>

@property (nonatomic, strong) HKTCPClient *client;
@property (nonatomic, strong) HKTCPServer *server;

- (void)sendCmd:(NSString *)targetAppURLSchema params:(NSDictionary *)params;

@end

@implementation WXHongBaoIPCCmdMgr

+ (instancetype)shareInstance
{
    static id sss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sss = [[[self class] alloc] init];
    });
    
    return sss;
}

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
        {
            //主号－服务器
            self.server = [[HKTCPServer alloc] init];
            self.server.delegate = self;
            [self.server start:KWXHongBaoIPCPort];
        }
        else
        {
            //小号－客户端
            NSString *masterIPAddress = [[WXHongBaoSettingMgr shareInstance] masterIPAddress];
            self.client = [[HKTCPClient alloc] init];
            self.client.delegate = self;
            [self.client connect:masterIPAddress port:KWXHongBaoIPCPort];
        }
    }
    
    return self;
}

- (BOOL)onCmdArrived:(NSString *)cmds
{
    //NSString *log = [NSString stringWithFormat:@"收到Cmds:%@", cmds];
    //HKTagNSLog(KWeChatHookSDKLog, log) ;
    
    NSString *cmdPrefix = [self cmdPrefix];
    if ( [cmds hasPrefix:cmdPrefix] )
    {
        NSString *cmdString = [cmds substringFromIndex:[NSString stringWithFormat:@"%@", cmdPrefix].length];
        
        [self handleCmds:cmdString];
        
        return YES;
    }
    
    return NO;
}

- (void)handleCmds:(NSString *)cmdString
{
    NSArray *cmdsList = [cmdString componentsSeparatedByString:KWeChatCmdsSpliteString];
    for ( NSString * cmd in cmdsList )
    {
        NSArray *cmdBody = [cmd componentsSeparatedByString:KWeChatCmdSpliteString];
        if ( cmdBody.count != 2 )
        {
            NSString *log = [NSString stringWithFormat:@"错误cmd:%@",cmd];
            HKTagNSLog(KWeChatHookSDKLog, log);
            continue;
        }
        
        NSString *cmd = [cmdBody objectAtIndex:0];
        NSString *value = [cmdBody objectAtIndex:1];
        
        [self handleCmd:cmd value:value];
    }
}

- (void)handleCmd:(NSString *)cmd value:(NSString *)value
{
    NSString *log = [NSString stringWithFormat:@"处理Cmd %@:%@", cmd, value];
    HKTagNSLog(KWeChatHookSDKLog, log);
    
    if ( [cmd isEqualToString:KWeChatCmdAutoOpenHongBao] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"收到领取通知"];
        [[WXHongBaoQueryTaskMgr shareInstance] stopQueryHongBaoStateTask:value];
        [[WXHongBaoOpeartionMgr shareInstance] openHongBaoByNativeURL:value usingCacheTimingId:YES log:YES];
    }
    
    if ( [cmd isEqualToString:KWeChatCmdLog] )
    {
        NSDictionary *userInfo = @{KWXHongBaoIPCCmdMgrLogKey:value};
        [[NSNotificationCenter defaultCenter] postNotificationName:KWXHongBaoIPCCmdMgrLogArrived object:nil userInfo:userInfo];
    }
    
    if ( [cmd isEqualToString:KWeChatCmdActiveApp] )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:value]];
        });
    }
    
    if ( [cmd isEqualToString:KWeChatCmdKeepAlive] )
    {
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"收到激活通知"];
    }
    
    if ( [cmd isEqualToString:KWeChatCmdConfig] )
    {
        [[WXHongBaoSettingMgr shareInstance] configByConfigString:value];
    }
}

- (void)sendCmd:(NSString *)targetAppURLSchema params:(NSDictionary *)params
{
    [self sendCmd:targetAppURLSchema params:params sendToAllClient:YES];
}

- (void)sendCmd:(NSString *)targetAppURLSchema params:(NSDictionary *)params sendToAllClient:(BOOL)sendToAllClient
{
    NSMutableString *cmds = [NSMutableString stringWithFormat:@""];
    
    for ( NSString *key in [params allKeys] )
    {
        NSString *value = [params objectForKey:key];
        NSString *cmd = [NSString stringWithFormat:@"%@%@%@", key, KWeChatCmdSpliteString, value];
        
        if ( ![cmds isEqualToString:@""] )
        {
            [cmds appendString:KWeChatCmdsSpliteString];
        }
        
        [cmds appendString:cmd];
    }
    
    NSString *totalCmd = [NSString stringWithFormat:@"%@%@", targetAppURLSchema, cmds];
    
    //NSString *log = [NSString stringWithFormat:@"totalCmd = %@", totalCmd];
    //HKTagNSLog(KWeChatHookSDKLog, log);
    
    [self sendCmd:targetAppURLSchema totalCmd:totalCmd sendToAllClient:sendToAllClient];
}

- (void)sendCmd:(NSString *)targetAppURLSchema totalCmd:(NSString *)totalCmd sendToAllClient:(BOOL)sendToAllClient
{
    if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        if ( [targetAppURLSchema isEqualToString:KWeChatOneURLSchema] )
        {
            //服务器发给自己
            [self onCmdArrived:totalCmd];
        }
        else
        {
            //服务器发给小号
            
            if ( sendToAllClient )
            {
                [self.server sendDataToAllClient:totalCmd];
            }
            else
            {
                [self.server sendDataToPreferredClient:totalCmd];
            }
        }
        
    }
    else
    {
        if ( [targetAppURLSchema isEqualToString:KWeChatTwoURLSchema] )
        {
            //小号发给自己
            [self onCmdArrived:totalCmd];
        }
        else
        {
            //小号发给服务器
            [self.client send:totalCmd];
        }
    }
}

- (NSString *)cmdPrefix
{
    if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        return KWeChatOneURLSchema;
    }
    else
    {
        return KWeChatTwoURLSchema;
    }
}

- (void)sendLogCmdWithFromApp:(NSString *)log
{
    NSString *fixLog = [self appendFromAppToLog:log];
    [self sendLogCmd:fixLog];
}

- (void)sendLogCmd:(NSString *)log
{
    if ( log == nil )
    {
        return;
    }
    
    NSDictionary *params = @{KWeChatCmdLog:log};
    [self sendCmd:KWeChatOneURLSchema params:params];
}

- (void)sendAutoOpenHongBao:(NSString *)nativeURL
{
    if ( nativeURL == nil )
    {
        return;
    }
    
    NSDictionary *params = @{KWeChatCmdAutoOpenHongBao:nativeURL};
    [self sendCmd:KWeChatTwoURLSchema params:params sendToAllClient:NO];
}

- (void)sendKeepAliveCmd
{
    NSDictionary *params = @{KWeChatCmdKeepAlive:@""};
    [self sendCmd:KWeChatTwoURLSchema params:params];
}

- (void)sendConfigCmd:(NSString *)config
{
    if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        NSDictionary *params = @{KWeChatCmdConfig:config};
        [self sendCmd:KWeChatTwoURLSchema params:params];
    }
}

- (NSString *)appendFromAppToLog:(NSString *)log
{
    NSString *fromApp = @"[主号]";
    
    if ( ![[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        fromApp = @"[小号]";
    }
    
    NSMutableString *string = [NSMutableString string];
    
    [string appendString:fromApp];
    [string appendString:log];
    
    return string;
}

//delegate

- (void)onServerDataArrived:(NSString *)data
{
    [self onCmdArrived:data];
}

- (void)onServerSocketDisconnected
{
    [self sendLogCmdWithFromApp:@"小号已断开"];
}

- (void)onServerSocketConntcted
{
    
}

//
- (void)onClientDataArrived:(NSString *)data
{
    [self onCmdArrived:data];
}

- (void)onClientSocketDisconnected
{
    
}

- (void)onClientSocketConntcted
{
    [self sendLogCmdWithFromApp:@"小号已连接"];
}

@end
