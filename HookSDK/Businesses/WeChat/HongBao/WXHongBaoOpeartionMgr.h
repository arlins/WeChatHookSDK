//
//  WXHongBaoOpeartionMgr.h
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import "WeChatRedEnvelop.h"

@interface WXHongBaoOpeartionMgr : NSObject

+ (instancetype)shareInstance;

- (void)wxQueryRedEnvelopesDetailRequest:(NSDictionary *)arg1;
- (void)wxOpenRedEnvelopesRequest:(NSDictionary *)params;

- (void)openHongBaoAccordingToSetting:(CMessageWrap *)wrap;
- (void)openHongBaoByNativeURL:(NSString *)nativeURL usingCacheTimingId:(BOOL)usingCacheTimingId log:(BOOL)log;
- (void)openHongBaoByMessageWrap:(CMessageWrap *)wrap log:(BOOL)log;

- (BOOL)testHongBaoMessageCanAutoOpen:(CMessageWrap *)wrap log:(BOOL)log;
- (BOOL)testHongBaoMessageCanOpen:(CMessageWrap *)wrap authTitle:(BOOL)authTitle log:(BOOL)log;

- (NSString *)getMyNickName;

- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap;

@end
