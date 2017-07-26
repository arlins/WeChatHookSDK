//
//  WXHongBaoReporter.m
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoReporter.h"

@implementation WXHongBaoReporter

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (void)initReporter
{
    
}

- (NSString *)reportAmountInfoToServer:(NSUInteger)amount
                          appKey:(NSString *)appKey
                     accountName:(NSString *)accountName
                    accountStyle:(NSString *)accountStyle

{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSMutableString *log = [NSMutableString string];
    NSString *spliteString = @",";
    //NSString *key = [NSString stringWithFormat:@"appkey_%@",appKey];
    
    [log appendString:dateString];
    [log appendString:spliteString];
    [log appendString:[NSString stringWithFormat:@"account_name:%@", accountName]];
    [log appendString:spliteString];
    [log appendString:[NSString stringWithFormat:@"account_style:%@", accountStyle]];
    [log appendString:spliteString];
    [log appendString:[NSString stringWithFormat:@"recv_amount:%d", (int)amount]];
    
    return log;
}

@end
