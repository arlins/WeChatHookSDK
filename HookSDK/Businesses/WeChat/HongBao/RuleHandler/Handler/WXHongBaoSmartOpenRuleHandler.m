//
//  WXHongBaoSmartOpenRuleHandler.m
//  HookSDK
//
//  Created by arlin on 17/4/11.
//
//

#import "WXHongBaoSmartOpenRuleHandler.h"
#import "WXHongBaoRuleUtility.h"
#import "NSData+HKCache.h"
#import "WXHongBaoTitleInfo.h"
#import "WeChatCommonDefine.h"

NSString *const KWXHongBaoSmartAnalyzeRuleLeftCount = @"KWXHongBaoSmartAnalyzeRuleLeftCount";
NSString *const KWXHongBaoSmartAnalyzeRuleLeftPercent = @"KWXHongBaoSmartAnalyzeRuleLeftPercent";

@interface WXHongBaoSmartOpenRuleHandler ()

@end

@implementation WXHongBaoSmartOpenRuleHandler

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
        item.name = KWXHongBaoSmartAnalyzeRuleLeftCount;
        item.title = [NSString stringWithFormat:@"开始剩余个数"];
        item.switchShow = NO;
        item.text = @"2";
        item.switchOn = NO;
        
        [list addObject:item];
    }
    
    {
        WXHongBaoSettingInfoItem *item = [[WXHongBaoSettingInfoItem alloc] init];
        item.name = KWXHongBaoSmartAnalyzeRuleLeftPercent;
        item.title = [NSString stringWithFormat:@"单个包剩余比例(1-100)"];
        item.switchShow = NO;
        item.text = @"20";
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
        self.style = WXHongBaoRuleStyleSmartOpen;
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
    if ( totalCount - recvCount >  [self leftCount] )
    {
        return WXHongBaoRuleMatchResultIgnore;
    }
    
    //剩下leftCount个，开始抢
    if ( totalCount - recvCount == 0 )
    {
        [log addObject:@"红包被领完了"];
        return WXHongBaoRuleMatchResultInvaild;
    }
    
    NSUInteger leftAmount = totalAmount - recvAmount;
    NSUInteger leftCount = totalCount - recvCount;
    float expectAllLeftPercent = [self expectLeftPercent] * leftCount;
    float realLeftPercent = ((float)leftAmount) / totalAmount;
    
    NSString *leftLog = [NSString stringWithFormat:@"剩余%d个,剩余%.2f", (int)leftCount, leftAmount*0.01];
    [log addObject:leftLog];
    
    if ( realLeftPercent >= expectAllLeftPercent )
    {
        return WXHongBaoRuleMatchResultValid;
    }
    else
    {
        [log addObject:@"不满足剩余条件小号不抢"];
        return WXHongBaoRuleMatchResultInvaild;
    }
}

- (NSUInteger)leftCount
{
    WXHongBaoSettingInfoItem *item = [self settingInfoOfKey:KWXHongBaoSmartAnalyzeRuleLeftCount];
    if ( item == nil )
    {
        return 0;
    }
    
    return item.text.integerValue;
}

- (float)expectLeftPercent
{
    WXHongBaoSettingInfoItem *item = [self settingInfoOfKey:KWXHongBaoSmartAnalyzeRuleLeftPercent];
    if ( item == nil )
    {
        return 100;
    }
    
    NSUInteger percent = item.text.intValue;
    percent = percent > 100 ? 100:percent;
    percent = percent < 1 ? 1:percent;
    
    return percent * 0.01;
}

- (WXHongBaoTitleInfo *)spliteTitleInfo:(NSString *)title
{
    WXHongBaoTitleInfo *titleInfo = [WXHongBaoRuleUtility smartSpliteTitleInfo:title];
    
    return titleInfo;
}

@end
