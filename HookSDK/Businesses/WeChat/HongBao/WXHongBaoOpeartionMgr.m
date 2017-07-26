//
//  WXHongBaoOpeartionMgr.m
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import "WXHongBaoOpeartionMgr.h"
#import "WeChatRedEnvelop.h"
#import "NSObject+HKMethodSwizzed.h"
#import "WeChatHookSDK.h"
#import "NSObject+HSClassInfo.h"
#import "NSDictionary+HKPrint.h"
#import "WeChatRedEnvelopParam.h"
#import <objc/runtime.h>
#import "NSDictionary+HKPrint.h"
#import "WXHongBaoMessageListMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoRuleManager.h"
#import "WXHongBaoQueryTaskMgr.h"

@implementation WXHongBaoOpeartionMgr

+ (instancetype)shareInstance
{
    static id sss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sss = [[[self class] alloc] init];
    });
    
    return sss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
       
    }
    
    return self;
}

- (void)wxQueryRedEnvelopesDetailRequest:(NSDictionary *)arg1
{
    WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
    [logicMgr QueryRedEnvelopesDetailRequest:arg1];
}

- (void)wxOpenRedEnvelopesRequest:(NSDictionary *)params
{
    WCRedEnvelopesLogicMgr *logicMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"WCRedEnvelopesLogicMgr")];
    [logicMgr OpenRedEnvelopesRequest:params];
}

- (void)openHongBaoAccordingToSetting:(CMessageWrap *)wrap
{
    if ( ![[WXHongBaoMessageListMgr shareInstance] isHongBaoMessage:wrap] )
    {
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"不是红包消息"];
        }
        return;
    }
    
    BOOL canOpenBySetting = [self testHongBaoMessageCanAutoOpen:wrap log:YES];
    if ( !canOpenBySetting )
    {
        return;
    }
    
    float openDelay = [[WXHongBaoSettingMgr shareInstance] openDelay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(openDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openHongBaoByMessageWrap:wrap log:YES];
    });
}

- (void)openHongBaoByNativeURL:(NSString *)nativeURL usingCacheTimingId:(BOOL)usingCacheTimingId log:(BOOL)log
{
    NSDictionary *dic = [[WXHongBaoMessageListMgr shareInstance] hongBaoParseNativeURL:nativeURL];
    
    NSString *sendId = [dic stringForKey:@"sendid"];
    NSString *timingId = nil;
    CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:sendId];
    
    if ( usingCacheTimingId )
    {
        timingId = [[WXHongBaoMessageListMgr shareInstance] timingIdOfName:sendId];;
    }
    
    if ( timingId != nil )
    {
        WeChatRedEnvelopParam *mgrParams = [[WXHongBaoMessageListMgr shareInstance] hongBaoEnvelopParamWithMessage:wrap];
        
        mgrParams.timingIdentifier = timingId;
        
        HKTagNSLog(KWeChatHookSDKLog, @"使用极速抢包");
        if ( log )
        {
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"使用极速抢包"];
            }
        }
        
        [[WXHongBaoOpeartionMgr shareInstance] wxOpenRedEnvelopesRequest:[mgrParams toParams]];
    }
    else
    {
        [self openHongBaoByMessageWrap:wrap log:log];
    }
    
}

- (void)openHongBaoByMessageWrap:(CMessageWrap *)wrap log:(BOOL)log
{
    HKTagNSLog(KWeChatHookSDKLog, @"WXHongBaoOpeartionMgr::openHongBaoByMessageWrap");
    
    if ( ![[WXHongBaoMessageListMgr shareInstance] isHongBaoMessage:wrap] )
    {
        HKTagNSLog(KWeChatHookSDKLog,@"打开红包无效");
        
        if ( log )
        {
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"打开红包无效"];
            }
        }
        
        return;
    }
    
    // 红包
    BOOL isRedEnvelopMessage = [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
    
    if (!isRedEnvelopMessage)
    {
        HKTagNSLog(KWeChatHookSDKLog,@"消息不是红包");
        
        if ( log )
        {
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"消息不是红包"];
            }
        }

        return;
    }
    
    /** 获取服务端验证参数 */
    void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
        NSMutableDictionary *params = [@{} mutableCopy];
        params[@"agreeDuty"] = @"0";
        params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
        params[@"inWay"] = @"0";
        params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
        params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
        params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
        
        WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
        [logicMgr ReceiverQueryRedEnvelopesRequest:params];
    };
    
    {
        NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
        NSDictionary *nativeUrlDict = [[WXHongBaoMessageListMgr shareInstance] hongBaoParseNativeURL:nativeUrl];
        
        if ( log )
        {
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"查询红包状态"];
            }
        }
        
        [[WXHongBaoMessageListMgr shareInstance] addAutoOpenHongBaoMesage:wrap];
        
        queryRedEnvelopesReqeust(nativeUrlDict);
    }
}

- (BOOL)testHongBaoMessageCanAutoOpen:(CMessageWrap *)wrap log:(BOOL)log
{
    HKTagNSLog(KWeChatHookSDKLog, @"WXHongBaoOpeartionMgr::testHongBaoMessageCanAutoOpen");
    
    
    BOOL autoOpen = [[WXHongBaoSettingMgr shareInstance] autoOpen];
    
    if ( !autoOpen )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"自动抢包关闭");
        
        if ( log )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"自动抢包关闭"];
        }
        
        return NO;
    }
    
    BOOL testHongBaoMessageCanOpen = [self testHongBaoMessageCanOpen:wrap authTitle:YES log:log];
    if ( !testHongBaoMessageCanOpen )
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)testHongBaoMessageCanOpen:(CMessageWrap *)wrap authTitle:(BOOL)authTitle log:(BOOL)log
{
    HKTagNSLog(KWeChatHookSDKLog, @"WXHongBaoOpeartionMgr::testHongBaoMessageCanOpen");
    NSString *groupName = [[WXHongBaoMessageListMgr shareInstance] groupNameFromMessage:wrap];
    NSString *title = [[WXHongBaoMessageListMgr shareInstance] hongBaoTitleWithMessage:wrap];
    BOOL isAppAuthorized = [[WXHongBaoSettingMgr shareInstance] isAppAuthorized];
    BOOL isEnable = [[WXHongBaoSettingMgr shareInstance] isEnable];
    BOOL isGroupNameVaild = [[WXHongBaoSettingMgr shareInstance] isGroupNameVaild:groupName];
    BOOL openOnlySendByMe = [[WXHongBaoSettingMgr shareInstance] openOnlySendByMe];
    BOOL isSendByMe = [[WXHongBaoMessageListMgr shareInstance] isSendByMe:wrap];
    
    NSString *logString = [NSString stringWithFormat:@"groupName = %@ titleInfo: %@",groupName, title];
    HKTagNSLog(KWeChatHookSDKLog, logString);
    
    logString = [NSString stringWithFormat:@"GetChatName = %@ ", [wrap GetChatName]];
    HKTagNSLog(KWeChatHookSDKLog, logString);
    
    if ( !isAppAuthorized )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"软件未授权");
        if ( log )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"软件未授权"];
        }
        
        return NO;
    }
    
    if ( !isEnable )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"总开关关闭");
        if ( log )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"总开关关闭"];
        }
        
        return NO;
    }
    
    if ( !isGroupNameVaild )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"群名称不在白名单");
        if ( log )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"群不在白名单"];
        }
        
        return NO;
    }
    
    if ( openOnlySendByMe && !isSendByMe )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"不是自己发的包不抢");
        if ( log )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"不是自己发的包不抢"];
        }
        
        return NO;
    }
    
    if ( authTitle )
    {
        BOOL titleVaild = [self testCanOpenHongBao:wrap log:log];
        if ( !titleVaild )
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)testCanOpenHongBao:(CMessageWrap *)wrap log:(BOOL)log
{
    HKTagNSLog(KWeChatHookSDKLog, @"WXHongBaoOpeartionMgr::testCanOpenHongBao");
    NSString *title = [[WXHongBaoMessageListMgr shareInstance] hongBaoTitleWithMessage:wrap];
    NSMutableArray *logArray = [NSMutableArray array];
    BOOL testCanOpenHongBao = [[WXHongBaoRuleManager shareInstance] testCanOpenHongBao:title log:logArray];
    if ( !testCanOpenHongBao )
    {
        //输出错误日志
        for ( NSString *errorLog in logArray )
        {
            HKTagNSLog(KWeChatHookSDKLog, errorLog);
            if ( log )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:errorLog];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (NSString *)getMyNickName
{
    CContactMgr *contactManager = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
    CContact *selfContact = [contactManager getSelfContact];
    
    return [selfContact getContactDisplayName];
}

- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap
{
    BOOL canNotice = [[WXHongBaoSettingMgr shareInstance] canNotice];
    BOOL isMaster = [[WXHongBaoSettingMgr shareInstance] isMaster];
    
    if ( isMaster )
    {
        if ( ![[WXHongBaoOpeartionMgr shareInstance] testHongBaoMessageCanOpen:wrap authTitle:YES log:YES] )
        {
            return;
        }
        
        if ( canNotice )
        {
            [[WXHongBaoQueryTaskMgr shareInstance] startQueryHongBaoDetailTask:wrap];
        }
        else
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"不通知小号"];
        }
    }
}

@end
