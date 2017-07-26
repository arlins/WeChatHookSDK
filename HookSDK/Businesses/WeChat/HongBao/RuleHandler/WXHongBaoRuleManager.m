//
//  WXHongBaoRuleManager.m
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoRuleManager.h"
#import "NSData+HKCache.h"
#import "WXHongBaoTitleInfo.h"
#import "WXHongBaoRuleUtility.h"
#import "WXHongBaoRuleHandler.h"
#import "WXHongBaoHitRuleHandler.h"
#import "WXHongBaoSmallRuleHandler.h"
#import "WXHongBaoSmartOpenRuleHandler.h"

@interface WXHongBaoRuleManager ()

@property (nonatomic, strong) NSMutableArray *ruleHandlersList;

@end

@implementation WXHongBaoRuleManager

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        [self initRules];
    }
    
    return self;
}

- (void)initRules
{
    [self registRuleHandler:[[WXHongBaoHitRuleHandler alloc] init]];
    [self registRuleHandler:[[WXHongBaoSmallRuleHandler alloc] init]];
    [self registRuleHandler:[[WXHongBaoSmartOpenRuleHandler alloc] init]];
    
    if ( self.currentRuleStyle == WXHongBaoRuleStyleNone )
    {
        self.currentRuleStyle = WXHongBaoRuleStyleHit;
    }
}

- (void)clearLocalConfig
{
    for ( WXHongBaoRuleHandler *handler in self.ruleHandlersList )
    {
        [handler clearLocalConfig];
    }
}

- (BOOL)testCanOpenHongBao:(NSString *)title log:(NSMutableArray *)log
{
    BOOL canOpen = NO;
    WXHongBaoRuleHandler *handler = [self ruleHandlerOfStyle:self.currentRuleStyle];
    if ( handler )
    {
        canOpen = [handler testCanOpenHongBao:title log:log];
    }
    
    return canOpen;
}

- (WXHongBaoRuleMatchResult)testQueryDetail:(NSUInteger)totalCount
              recvCount:(NSUInteger)recvCount
            totalAmount:(NSUInteger)totalAmount
             recvAmount:(NSUInteger)recvAmount
               recvList:(NSArray *)recvList 
                  title:(NSString *)title
                    log:(NSMutableArray *)log
{
    WXHongBaoRuleMatchResult res = WXHongBaoRuleMatchResultIgnore;
    WXHongBaoRuleHandler *handler = [self ruleHandlerOfStyle:self.currentRuleStyle];
    if ( handler )
    {
        res = [handler testQueryDetail:totalCount recvCount:recvCount totalAmount:totalAmount recvAmount:recvAmount recvList:recvList title:title log:log];
    }
    
    return res;
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
    BOOL res = NO;
    WXHongBaoRuleHandler *handler = [self ruleHandlerOfStyle:self.currentRuleStyle];
    if ( handler )
    {
        res = [handler testOpenResultTip:totalCount recvCount:recvCount totalAmount:totalAmount recvAmount:recvAmount recvList:recvList amountByMe:amountByMe title:title log:log];
    }
    
    return res;
}

- (void)setCurrentRuleStyle:(WXHongBaoRuleStyle)currentRuleStyle
{
    for ( WXHongBaoRuleHandler *handler in self.ruleHandlersList )
    {
        if ( handler.style == currentRuleStyle )
        {
            handler.enable = YES;
        }
        else
        {
            handler.enable = NO;
        }
    }
}

- (WXHongBaoRuleStyle)currentRuleStyle
{
    for ( WXHongBaoRuleHandler *handler in self.ruleHandlersList )
    {
        if ( handler.enable )
        {
            return handler.style;
        }
    }
    
    return WXHongBaoRuleStyleNone;
}

- (void)registRuleHandler:(WXHongBaoRuleHandler *)handler
{
    if ( self.ruleHandlersList == nil )
    {
        self.ruleHandlersList = [NSMutableArray array];
    }
    
    [self.ruleHandlersList addObject:handler];
}

- (WXHongBaoRuleHandler *)ruleHandlerOfStyle:(WXHongBaoRuleStyle)style
{
    for ( WXHongBaoRuleHandler *handler in self.ruleHandlersList )
    {
        if ( handler.style == style )
        {
            return handler;
        }
    }
    
    return nil;
}

@end
