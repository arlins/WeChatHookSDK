//
//  WXHongBaoSmallRuleHandler.m
//  HookSDK
//
//  Created by dps on 17/3/31.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "WXHongBaoSmallRuleHandler.h"
#import "WXHongBaoRuleUtility.h"
#import "NSData+HKCache.h"
#import "WXHongBaoTitleInfo.h"
#import "WeChatCommonDefine.h"

NSString *const KWXHongBaoSmallRuleHandlerWhiteList = @"KWXHongBaoSmallRuleHandlerWhiteList";

@implementation WXHongBaoSmallRuleHandler

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
        item.name = KWXHongBaoSmallRuleHandlerWhiteList;
        item.title = [NSString stringWithFormat:@"免死白名单微信号(%@隔开)", KWXHongBaoRuleHitTitleStringSplite];
        item.switchShow = NO;
        item.text = @"";
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
        self.style = WXHongBaoRuleStyleSmall;
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
    
    return YES;
}

- (WXHongBaoRuleMatchResult)testQueryDetail:(NSUInteger)totalCount
                                  recvCount:(NSUInteger)recvCount
                                totalAmount:(NSUInteger)totalAmount
                                 recvAmount:(NSUInteger)recvAmount
                                   recvList:(NSArray *)recvList
                                      title:(NSString *)title
                                        log:(NSMutableArray *)log
{
    if ( totalCount - recvCount > 1 )
    {
        return WXHongBaoRuleMatchResultIgnore;
    }
    
    //剩下最后一个，或者被领完了
    
    if ( totalCount - recvCount == 1 )
    {
        NSInteger leftAmount = totalAmount - recvAmount;
        BOOL isLeftAmountSmallest = [self isLeftAmountVaild:recvList leftAmount:leftAmount];
        
        NSString *leftLog = [NSString stringWithFormat:@"尾包为%.2f", leftAmount*0.01];
        [log addObject:leftLog];
        
        if ( isLeftAmountSmallest )
        {
            return WXHongBaoRuleMatchResultValid;
        }
        else
        {
            [log addObject:@"尾包最小小号不抢"];
            return WXHongBaoRuleMatchResultInvaild;
        }
    }
    else
    {
        [log addObject:@"红包被领完了"];
        return WXHongBaoRuleMatchResultInvaild;
    }
}

- (BOOL)isLeftAmountVaild:(NSArray *)recvList leftAmount:(NSUInteger)leftAmount
{
    NSArray *fixList = [self fixRecordByWhiteList:recvList];
    NSUInteger smallAmount = 999999;
    for ( WXHongBaoRecvRecordInfo *info in fixList )
    {
        if ( info.receiveAmount < smallAmount )
        {
            smallAmount = info.receiveAmount;
        }
    }
    
    BOOL vaild = leftAmount > smallAmount;
    
    return vaild;
}

- (NSArray *)fixRecordByWhiteList:(NSArray *)recvList
{
    WXHongBaoSettingInfoItem *item = [self settingInfoOfKey:KWXHongBaoSmallRuleHandlerWhiteList];
    if ( item == nil )
    {
        return recvList;
    }
    
    NSMutableArray *list = [NSMutableArray arrayWithArray:recvList];
    NSArray *whiteList = [item.text componentsSeparatedByString:KWXHongBaoRuleHitTitleStringSplite];
    for ( NSString *userName in whiteList )
    {
        for ( WXHongBaoRecvRecordInfo *info in list )
        {
            if ( ![info.userName isEqualToString:userName] )
            {
                continue;
            }
            
            [list removeObject:info];
            break;
        }
    }
    
    return list;
}

@end
