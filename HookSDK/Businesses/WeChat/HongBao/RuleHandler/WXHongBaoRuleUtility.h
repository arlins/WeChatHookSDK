//
//  WXHongBaoRuleUtility.h
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXHongBaoTitleInfo;

@interface WXHongBaoRuleUtility : NSObject

+ (BOOL)isNumberStringMayEqual:(NSString *)numberString to:(NSString *)anotherNumberString;

+ (BOOL)isNumberChar:(NSString *)charString;

+ (WXHongBaoTitleInfo *)smartSpliteTitleInfo:(NSString *)titleString;

@end
