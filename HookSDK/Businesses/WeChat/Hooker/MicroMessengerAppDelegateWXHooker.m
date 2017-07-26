//
//  MicroMessengerAppDelegate+WXHooker.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "MicroMessengerAppDelegateWXHooker.h"
#import <UIKit/UIKit.h>
#import "WeChatHookSDK.h"
#import "HKCommonDefine.h"
#import "NSDictionary+HKPrint.h"
#import "NSObject+HKMethodSwizzed.h"
#import "NSDictionary+HKURL.h"
#import "WXHongBaoMessageListMgr.h"
#import "NSObject+HKMethodSwizzed.h"
#import "WeChatRedEnvelop.h"
#import "WeChatHookSDK.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "WeChatRedEnvelopParam.h"
#import "NSDictionary+HKPrint.h"
#import "WXHongBaoMessageListMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "WXHongBaoOpeartionMgr.h"
#import "WXHongBaoAssistantWindow.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoReporter.h"
#import "WXAutoChangeMyInfoMgr.h"

@interface MicroMessengerAppDelegateWXHooker ()

@end

@implementation MicroMessengerAppDelegateWXHooker

+ (void)call_handleOpenURL:(NSString *)url
{

}

- (BOOL)wxhk_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL ret = [self wxhk_application:application handleOpenURL:url];
    
    HKTagNSLog( KWeChatHookSDKLog, @"MicroMessengerAppDelegateWXHooker::handleOpenURL 1" );
    
    [MicroMessengerAppDelegateWXHooker call_handleOpenURL:url.absoluteString];
    
    return ret;
}

- (BOOL)wxhk_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    BOOL ret = [self wxhk_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    HKTagNSLog( KWeChatHookSDKLog, @"MicroMessengerAppDelegateWXHooker::handleOpenURL 2" );
    
    [MicroMessengerAppDelegateWXHooker call_handleOpenURL:url.absoluteString];
    
    return ret;
}

- (BOOL)wxhk_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    BOOL ret = [self wxhk_application:application openURL:url options:options];
    
    HKTagNSLog( KWeChatHookSDKLog, @"MicroMessengerAppDelegateWXHooker::handleOpenURL 3" );
    
    [MicroMessengerAppDelegateWXHooker call_handleOpenURL:url.absoluteString];
    
    return ret;
}

- (BOOL)wxhk_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    BOOL ret = [self wxhk_application:application didFinishLaunchingWithOptions:launchOptions];
    
    HKTagNSLog( KWeChatHookSDKLog, @"MicroMessengerAppDelegateWXHooker::didFinishLaunchingWithOptions" );
    
    [MicroMessengerAppDelegateWXHooker commonInit];
    
    return ret;
}

+ (void)hook
{
    HKTagNSLog( KWeChatHookSDKLog, @"MicroMessengerAppDelegateWXHooker::hook" );
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"MicroMessengerAppDelegateWXHooker") originalClass:NSClassFromString(@"MicroMessengerAppDelegate") swizzledSelector:@selector(wxhk_application:didFinishLaunchingWithOptions:) originalSelector:@selector(application:didFinishLaunchingWithOptions:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"MicroMessengerAppDelegateWXHooker") originalClass:NSClassFromString(@"MicroMessengerAppDelegate") swizzledSelector:@selector(wxhk_application:handleOpenURL:) originalSelector:@selector(application:handleOpenURL:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"MicroMessengerAppDelegateWXHooker") originalClass:NSClassFromString(@"MicroMessengerAppDelegate") swizzledSelector:@selector(wxhk_application:openURL:sourceApplication:annotation:) originalSelector:@selector(application:openURL:sourceApplication:annotation:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"MicroMessengerAppDelegateWXHooker") originalClass:NSClassFromString(@"MicroMessengerAppDelegate") swizzledSelector:@selector(wxhk_application:openURL:options:) originalSelector:@selector(application:openURL:options:)];
}

+ (void)commonInit
{
    [WXHongBaoSettingMgr shareInstance];
    [WXHongBaoIPCCmdMgr shareInstance];
    [WXHongBaoMessageListMgr shareInstance];
    [WXHongBaoOpeartionMgr shareInstance];
    [WXAutoChangeMyInfoMgr shareInstance];
    [[WXHongBaoReporter shareInstance] initReporter];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WXHongBaoAssistantWindow shareInstance] show];
            [[WXAutoChangeMyInfoMgr shareInstance] start];
        
            if ( [[WXHongBaoSettingMgr shareInstance] isMaster] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"初始化成功"];
            }
    });
}

@end
