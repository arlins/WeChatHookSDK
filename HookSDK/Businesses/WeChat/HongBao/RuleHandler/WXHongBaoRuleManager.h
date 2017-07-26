//
//  WXHongBaoRuleManager.h
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXHongBaoSettingMgr.h"

@class WXHongBaoRuleHandler;

typedef NS_ENUM(NSUInteger, WXHongBaoRuleStyle)
{
    WXHongBaoRuleStyleNone,
    WXHongBaoRuleStyleHit,
    WXHongBaoRuleStyleSmall,
    WXHongBaoRuleStyleSmartOpen
};

typedef NS_ENUM(NSUInteger, WXHongBaoRuleMatchResult)
{
    WXHongBaoRuleMatchResultValid,
    WXHongBaoRuleMatchResultInvaild,
    WXHongBaoRuleMatchResultIgnore,
};

@interface WXHongBaoRuleManager : NSObject

@property (nonatomic, assign) WXHongBaoRuleStyle currentRuleStyle;

+ (instancetype)shareInstance;

- (void)clearLocalConfig;

- (WXHongBaoRuleHandler *)ruleHandlerOfStyle:(WXHongBaoRuleStyle)style;

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
