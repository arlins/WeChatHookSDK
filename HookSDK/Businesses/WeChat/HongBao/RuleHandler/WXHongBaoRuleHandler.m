//
//  WXHongBaoRuleHandler.m
//  HookSDK
//
//  Created by arlin on 17/3/31.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "WXHongBaoRuleHandler.h"
#import "NSData+HKCache.h"

NSString *const KWXHongBaoRuleHandlerEnableKey = @"KWXHongBaoRuleHandlerEnableKey";
NSString *const KWXHongBaoRuleConfigUpdate = @"KWXHongBaoRuleConfigUpdate";

@implementation WXHongBaoRuleHandler

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.style = WXHongBaoRuleStyleNone;
    }
    
    return self;
}

- (void)initConfig
{
    self.config = [NSData hk_valueForKey:self.cacheKey];
    if ( self.config == nil )
    {
        self.config = [self defaultConfig];
    }
}

- (BOOL)testCanOpenHongBao:(NSString *)title log:(NSMutableArray *)log
{
    return NO;
}

- (WXHongBaoRuleMatchResult)testQueryDetail:(NSUInteger)totalCount
                                  recvCount:(NSUInteger)recvCount
                                totalAmount:(NSUInteger)totalAmount
                                 recvAmount:(NSUInteger)recvAmount
                                   recvList:(NSArray *)recvList
                                      title:(NSString *)title
                                        log:(NSMutableArray *)log
{
    return WXHongBaoRuleMatchResultIgnore;
}

- (BOOL)testOpenResultTip:(NSUInteger)totalCount
                recvCount:(NSUInteger)recvCount
              totalAmount:(NSUInteger)totalAmount
               recvAmount:(NSUInteger)recvAmount
                 recvList:(NSArray *)recvList
               amountByMe:(NSUInteger)amountByMe
                    title:(NSString *)title
                      log:(NSMutableArray *)log
{
    return NO;
}

- (void)updateRuleConfig:(WXHongBaoSettingInfoItem *)item
{
    if ( [item.name isEqualToString:KWXHongBaoRuleHandlerEnableKey]
        && item.switchOn )
    {
        [WXHongBaoRuleManager shareInstance].currentRuleStyle = self.style;
    }
    
    [self updateRuleConfigPrivate:item];
}

- (void)updateRuleConfigPrivate:(WXHongBaoSettingInfoItem *)item
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KWXHongBaoRuleConfigUpdate object:nil];
    
    [NSData hk_setValue:self.config forKey:self.cacheKey];
}

- (NSArray *)defaultConfig
{
    return [NSArray array];
}

- (void)clearLocalConfig
{
    [NSData hk_setValue:nil forKey:self.cacheKey];
}

- (WXHongBaoSettingInfoItem *)settingInfoOfKey:(NSString *)key
{
    for ( WXHongBaoSettingInfoItem *item in self.config )
    {
        if ( ![item isKindOfClass:[WXHongBaoSettingInfoItem class]] )
        {
            continue;
        }
        
        if ( [item.name isEqualToString:key] )
        {
            return item;
        }
    }
    
    return nil;
}

- (void)setEnable:(BOOL)enable
{
    WXHongBaoSettingInfoItem *item = [self settingInfoOfKey:KWXHongBaoRuleHandlerEnableKey];
    if ( item )
    {
        item.switchOn = enable;
        [self updateRuleConfigPrivate:item];
    }
}

- (BOOL)enable
{
    WXHongBaoSettingInfoItem *item = [self settingInfoOfKey:KWXHongBaoRuleHandlerEnableKey];
    if ( item )
    {
        return item.switchOn;
    }
    
    return NO;
}

@end
