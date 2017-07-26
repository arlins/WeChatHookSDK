//
//  WXHongBaoHitRuleHandler.m
//  HookSDK
//
//  Created by arlin on 17/3/31.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "WXHongBaoHitRuleHandler.h"
#import "WXHongBaoRuleUtility.h"
#import "NSData+HKCache.h"
#import "WXHongBaoTitleInfo.h"
#import "WeChatCommonDefine.h"

NSString *const KWXHongBaoRuleHitKeyTitleSplite = @"KWXHongBaoRuleHitKeyTitleSplite";
NSString *const KWXHongBaoRuleHitKeySmartTitleSplite = @"KWXHongBaoRuleHitKeySmartTitleSplite";

@interface WXHongBaoHitRuleHandler ()

@end

@implementation WXHongBaoHitRuleHandler

- (NSArray *)defaultConfig
{
    NSMutableArray *list = [NSMutableArray array];
    {
        WXHongBaoSettingInfoItem *item = [[WXHongBaoSettingInfoItem alloc] init];
        item.name = KWXHongBaoRuleHandlerEnableKey;
        item.title = @"开关";
        item.switchShow = YES;
        item.text = nil;
        item.switchOn = NO;
        
        [list addObject:item];
    }
    
    {
        WXHongBaoSettingInfoItem *item = [[WXHongBaoSettingInfoItem alloc] init];
        item.name = KWXHongBaoRuleHitKeySmartTitleSplite;
        item.title = @"智能解析标题";
        item.switchShow = YES;
        item.text = nil;
        item.switchOn = YES;
        
        [list addObject:item];
    }
    
    {
        WXHongBaoSettingInfoItem *item = [[WXHongBaoSettingInfoItem alloc] init];
        item.name = KWXHongBaoRuleHitKeyTitleSplite;
        item.title = [NSString stringWithFormat:@"红包标题分隔符(%@隔开)", KWXHongBaoRuleHitTitleStringSplite];
        item.switchShow = NO;
        item.text = @",|&|/|&|||&|:|&|-|&|=|&|*|&|#|&|;";
        item.switchOn = NO;
        
        [list addObject:item];
    }
    
    return list;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.style = WXHongBaoRuleStyleHit;
        self.cacheKey = NSStringFromClass([self class]);
        [self initConfig];
    }
    
    return self;
}

- (BOOL)testCanOpenHongBao:(NSString *)title log:(NSMutableArray *)log
{
    if ( !self.enable )
    {
        return NO;
    }
    
    WXHongBaoTitleInfo *titleInfo = [self spliteTitleInfo:title];
    BOOL vaild = titleInfo ? titleInfo.vaild : NO;
    
    if ( !vaild )
    {
        [log addObject:@"红包标题无效"];
    }
    
    return vaild;
}

- (WXHongBaoRuleMatchResult)testQueryDetail:(NSUInteger)totalCount
                                  recvCount:(NSUInteger)recvCount
                                totalAmount:(NSUInteger)totalAmount
                                 recvAmount:(NSUInteger)recvAmount
                                   recvList:(NSArray *)recvList
                                      title:(NSString *)title
                                        log:(NSMutableArray *)log
{
    //剩下最后一个，或者被领完了
    if ( totalCount - recvCount > 1 )
    {
        return WXHongBaoRuleMatchResultIgnore;
    }
    
    if ( totalCount - recvCount == 1 )
    {
        NSInteger leftAmount = totalAmount - recvAmount;
        NSInteger lastValue = leftAmount % 10;
        WXHongBaoTitleInfo *titleInfo = [self spliteTitleInfo:title];
     
        NSString *leftLog = [NSString stringWithFormat:@"尾包为%.2f,雷值为%d", leftAmount*0.01, (int)titleInfo.hit];
        [log addObject:leftLog];
        
        if ( titleInfo && titleInfo.vaild )
        {
            if ( lastValue != titleInfo.hit )
            {
                return WXHongBaoRuleMatchResultValid;
            }
            else
            {
                [log addObject:@"尾包命中雷值小号不抢"];
                return WXHongBaoRuleMatchResultInvaild;
            }
        }
        else
        {
            [log addObject:@"红包标题无效"];
            return WXHongBaoRuleMatchResultInvaild;
        }
    }
    else
    {
        [log addObject:@"红包被领完了"];
        return WXHongBaoRuleMatchResultInvaild;
    }
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
    NSInteger leftAmount = totalAmount - recvAmount;
    NSInteger lastValue = leftAmount % 10;
    WXHongBaoTitleInfo *titleInfo = [self spliteTitleInfo:title];
    
    if ( titleInfo && titleInfo.vaild )
    {
        if ( lastValue == titleInfo.hit )
        {
            return YES;
        }
    }
    
    return NO;
}

- (WXHongBaoTitleInfo *)spliteTitleInfo:(NSString *)title
{
    WXHongBaoSettingInfoItem *canSmartSpliteTitle = [self settingInfoOfKey:KWXHongBaoRuleHitKeySmartTitleSplite];
    WXHongBaoSettingInfoItem *spliteTitle = [self settingInfoOfKey:KWXHongBaoRuleHitKeyTitleSplite];
    
    if ( canSmartSpliteTitle == nil || spliteTitle == nil )
    {
        return nil;
    }
    
    WXHongBaoTitleInfo *titleInfo = nil;
    if ( canSmartSpliteTitle.switchOn )
    {
        titleInfo = [WXHongBaoRuleUtility smartSpliteTitleInfo:title];
    }
    else
    {
        NSArray *spliteList = [spliteTitle.text componentsSeparatedByString:KWXHongBaoRuleHitTitleStringSplite];
        
        titleInfo = [[WXHongBaoTitleInfo alloc] initWithTitle:title splites:spliteList];
    }
    
    return titleInfo;
}

@end
