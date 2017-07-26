//
//  WXHongBaoMessageListMgr.h
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import "WeChatRedEnvelop.h"
#import "WeChatRedEnvelopParam.h"

@interface WXHongBaoMessageListMgr : NSObject

@property (nonatomic, strong) NSMutableArray<CMessageWrap *> *messageList;
@property (nonatomic, strong) NSMutableDictionary *timingIdDictionary;

+ (instancetype)shareInstance;

- (void)addHongBaoMessage:(CMessageWrap *)message;

- (BOOL)isHongBaoMessage:(CMessageWrap *)wrap;

- (CMessageWrap *)hongBaoMessageBySendId:(NSString *)sendId;
- (NSString *)hongBaoNativeURLWithMessage:(CMessageWrap *)wrap;
- (NSDictionary *)hongBaoParseNativeURLWithMessage:(CMessageWrap *)wrap;
- (NSDictionary *)hongBaoParseNativeURL:(NSString *)nativeURL;
- (NSString *)sendIdFromNativeURL:(NSString *)nativeURL;
- (NSString *)sendIdFromMessage:(CMessageWrap *)wrap;
- (WeChatRedEnvelopParam *)hongBaoEnvelopParamWithMessage:(CMessageWrap *)wrap;
- (WeChatRedEnvelopParam *)hongBaoEnvelopParamWithSendId:(NSString *)sendId;

- (NSString *)hongBaoTitleWithMessage:(CMessageWrap *)wrap;
- (NSString *)groupNameFromMessage:(CMessageWrap *)wrap;

- (void)addAutoOpenHongBaoMesage:(CMessageWrap *)wrap;
- (BOOL)isAutoOpenHongBaoMesage:(CMessageWrap *)wrap;
- (BOOL)isSendByMe:(CMessageWrap *)wrap;

- (void)addTimingId:(NSString *)timingId name:(NSString *)name;
- (NSString *)timingIdOfName:(NSString *)name;

@end
