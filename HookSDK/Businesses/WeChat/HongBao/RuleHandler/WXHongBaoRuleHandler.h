//
//  WXHongBaoRuleHandler.h
//  HookSDK
//
//  Created by arlin on 17/3/31.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXHongBaoRuleManager.h"

extern NSString *const KWXHongBaoRuleHandlerEnableKey;
extern NSString *const KWXHongBaoRuleConfigUpdate;

@interface WXHongBaoRuleHandler : NSObject

@property (nonatomic, strong) NSArray *config;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, assign) WXHongBaoRuleStyle style;
@property (nonatomic, assign) BOOL enable;

- (NSArray *)defaultConfig;

- (void)initConfig;

- (void)clearLocalConfig;

- (void)updateRuleConfig:(WXHongBaoSettingInfoItem *)item;

- (WXHongBaoSettingInfoItem *)settingInfoOfKey:(NSString *)key;

- (BOOL)testCanOpenHongBao:(NSString *)title log:(NSMutableArray *)log;

- (WXHongBaoRuleMatchResult)testQueryDetail:(NSUInteger)totalCount
                                  recvCount:(NSUInteger)recvCount
                                totalAmount:(NSUInteger)totalAmount
                                 recvAmount:(NSUInteger)recvAmount
                                   recvList:(NSArray *)recvList
                                      title:(NSString *)title
                                        log:(NSMutableArray *)log;



- (BOOL)testOpenResultTip:(NSUInteger)totalCount
                recvCount:(NSUInteger)recvCount
              totalAmount:(NSUInteger)totalAmount
               recvAmount:(NSUInteger)recvAmount
                 recvList:(NSArray *)recvList
               amountByMe:(NSUInteger)amountByMe
                    title:(NSString *)title
                      log:(NSMutableArray *)log;

@end
