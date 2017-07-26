//
//  WeChatHookSDK.m
//  HookSDK
//
//  Created by dps on 17/3/10.
//
//

#import "WeChatHookSDK.h"
#import "HKCommonDefine.h"
#import "CaptainHook.h"
#import "NSObject+HSClassInfo.h"
#import "WeChatRedEnvelop.h"
#import "NSDictionary+HKPrint.h"
#import "MicroMessengerAppDelegateWXHooker.h"
#import "WCRedEnvelopesLogicMgrHooker.h"
#import "CMessageMgrHooker.h"
#import "NewSettingViewControllerHooker.h"

#pragma mark - HookSDK

@interface WeChatHookSDK ()


@end

@implementation WeChatHookSDK

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}



- (void)hook
{
    /**
     红包流程
     1：ReceiverQueryRedEnvelopesRequest 查询红包状态，是否领取过等等
     2：OpenRedEnvelopesRequest 没有领取过或者没有领完，领取红包
     3：QueryRedEnvelopesDetailRequest 查询红包状态
     **/
    
    Class app = NSClassFromString(@"MicroMessengerAppDelegateWXHooker");
    if ( app != Nil )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"开始注入");
        [MicroMessengerAppDelegateWXHooker hook];
        [WCRedEnvelopesLogicMgrHooker hook];
        [CMessageMgrHooker hook];
        [NewSettingViewControllerHooker hook];
    }
    else
    {
        HKTagNSLog(KWeChatHookSDKLog, @"不是微信客户端");
    }
}

@end
