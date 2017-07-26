//
//  WeChatCommonDefine.h
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import <Foundation/Foundation.h>

#define KWeChatHookSDKLog @"WeChatHook"
#define KWeChatOneURLSchema @"wechatone://"
#define KWeChatTwoURLSchema @"wechattwo://"

#define KWeChatBundleIdOne @"com.tencent.wechat.one"
#define KWeChatBundleIdTwo @"com.tencent.wechat.two"

#define KWeChatCmdsSpliteString @"|--|"
#define KWeChatCmdSpliteString @":--:"
#define KWeChatCmdAutoOpenHongBao @"cmd_auto_openhongbao"
#define KWeChatCmdKeepAlive @"cmd_keepalive"
#define KWeChatCmdActiveApp @"cmd_activeapp"
#define KWeChatCmdLog @"cmd_log"
#define KWeChatCmdConfig @"cmd_config"

#define KWeChatPrivateHookSDK

extern NSString *const KWXHongBaoRuleHitTitleStringSplite;

@interface WXHongBaoRecvRecordInfo : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSUInteger receiveAmount;

@end
