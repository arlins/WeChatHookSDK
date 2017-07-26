//
//  CMessageMgrHooker.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "CMessageMgrHooker.h"
#import "NSObject+HKMethodSwizzed.h"
#import "WeChatRedEnvelop.h"
#import "WeChatHookSDK.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "WeChatRedEnvelopParam.h"
#import "NSDictionary+HKPrint.h"
#import "WXHongBaoMessageListMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoOpeartionMgr.h"
#import "WXHongBaoQueryTaskMgr.h"

@implementation CMessageMgrHooker

- (void)wxhk_AsyncOnAddMsg:(NSString *)arg1 MsgWrap:(CMessageWrap *)arg2
{
    [self wxhk_AsyncOnAddMsg:arg1 MsgWrap:arg2];
    
    HKTagNSLog(KWeChatHookSDKLog, @"CMessageMgr::AsyncOnAddMsg");
    
    CMessageWrap *wrap = arg2;
    
    BOOL isHongBaoMessage =[[WXHongBaoMessageListMgr shareInstance] isHongBaoMessage:wrap];
    
    if ( isHongBaoMessage )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"红包来了");
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"红包来了"];
        }
        
        [[WXHongBaoMessageListMgr shareInstance] addHongBaoMessage:wrap];
        
        [CMessageMgrHooker tryToAutoOpenHongBao:wrap];
        [CMessageMgrHooker tryToAutoQueryHongBao:wrap];
    }
}

+ (void)hook
{
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"CMessageMgrHooker") originalClass:NSClassFromString(@"CMessageMgr") swizzledSelector:@selector(wxhk_AsyncOnAddMsg:MsgWrap:) originalSelector:@selector(AsyncOnAddMsg:MsgWrap:)];
}

+ (void)tryToAutoOpenHongBao:(CMessageWrap *)wrap
{
    //主号才会自动抢包
    BOOL sendByMe = [[WXHongBaoMessageListMgr shareInstance] isSendByMe:wrap];
    
    if ( sendByMe )
    {
        [[WXHongBaoOpeartionMgr shareInstance] startQueryHongBaoDetailTask:wrap];
    }
    else
    {
        if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
        {
            [[WXHongBaoOpeartionMgr shareInstance] openHongBaoAccordingToSetting:wrap];
        }
    }
}

+ (void)tryToAutoQueryHongBao:(CMessageWrap *)wrap
{
    //收到红包小号自动查询，提前获取timingId
    if ( ![[WXHongBaoSettingMgr shareInstance] isMaster] && [[WXHongBaoSettingMgr shareInstance] canQuickOpen] )
    {
        if ( [[WXHongBaoOpeartionMgr shareInstance] testHongBaoMessageCanOpen:wrap authTitle:NO log:NO ] ) {
            [[WXHongBaoQueryTaskMgr shareInstance] startQueryHongBaoStateTask:wrap.m_oWCPayInfoItem.m_c2cNativeUrl];
        }
    }
}

@end
