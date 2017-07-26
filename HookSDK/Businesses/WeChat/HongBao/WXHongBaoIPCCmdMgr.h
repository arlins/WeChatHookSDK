//
//  HongBaoIPCMgr.h
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const KWXHongBaoIPCCmdMgrLogArrived;
extern NSString *const KWXHongBaoIPCCmdMgrLogKey;

@interface WXHongBaoIPCCmdMgr : NSObject

+ (instancetype)shareInstance;

- (void)sendCmd:(NSString *)targetAppURLSchema params:(NSDictionary *)params sendToAllClient:(BOOL)sendToAllClient;

- (void)sendLogCmd:(NSString *)log;
- (void)sendLogCmdWithFromApp:(NSString *)log;
- (void)sendAutoOpenHongBao:(NSString *)nativeURL;
- (void)sendKeepAliveCmd;
- (void)sendConfigCmd:(NSString *)config;

- (BOOL)onCmdArrived:(NSString *)url;

@end
