//
//  WeChatCommonDefine.m
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import "WeChatCommonDefine.h"

NSString *const KWXHongBaoRuleHitTitleStringSplite = @"|&|";

@implementation WXHongBaoRecvRecordInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"user = %@, receiveAmount = %d", self.userName, (int)self.receiveAmount];
}

@end
