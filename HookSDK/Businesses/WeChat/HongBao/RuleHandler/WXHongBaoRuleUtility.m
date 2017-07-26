//
//  WXHongBaoRuleUtility.m
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "WXHongBaoRuleUtility.h"
#import "NSString+HKSearch.h"
#import "WXHongBaoRuleManager.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoTitleInfo.h"

@implementation WXHongBaoRuleUtility

+ (BOOL)isNumberChar:(NSString *)charString
{
    NSString *numberMatchString = @"0123456789";
    if ( [numberMatchString hk_containsString:charString] )
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isNumberStringMayEqual:(NSString *)numberString to:(NSString *)anotherNumberString
{
    if ( numberString.length == anotherNumberString.length )
    {
        BOOL totalEqual = YES;
        for ( int i = 0; i < numberString.length; i ++ )
        {
            NSString *charNumber0 = [numberString substringWithRange:NSMakeRange(i, 1)];
            NSString *charNumber1 = [anotherNumberString substringWithRange:NSMakeRange(numberString.length - i - 1, 1)];
            
            if ( ![self isNumberChar:charNumber0]
                || ![self isNumberChar:charNumber1]
                || ![charNumber0 isEqualToString:charNumber1] )
            {
                totalEqual = NO;
                break;
            }
        }
        
        return totalEqual;
    }
    
    return NO;
}

+ (WXHongBaoTitleInfo *)smartSpliteTitleInfo:(NSString *)titleString
{
    NSMutableString *firstNumberString = [NSMutableString stringWithFormat:@""];
    NSMutableString *lastNumberString = [NSMutableString stringWithFormat:@""];
    for ( int i = 0; i < titleString.length; i ++ )
    {
        NSRange range;
        range.location = i;
        range.length = 1;
        NSString * numberString = [titleString substringWithRange:range];
        BOOL isNumberChar = [WXHongBaoRuleUtility isNumberChar:numberString];
        if ( isNumberChar )
        {
            [firstNumberString appendString:numberString];
        }
        else
        {
            //找到数字组合了
            if ( ![firstNumberString isEqualToString:@""] )
            {
                break;
            }
        }
    }
    
    for ( int i = (int)titleString.length - 1; i >= 0; i -- )
    {
        NSRange range;
        range.location = i;
        range.length = 1;
        NSString * numberString = [titleString substringWithRange:range];
        BOOL isNumberChar = [WXHongBaoRuleUtility isNumberChar:numberString];
        if ( isNumberChar )
        {
            [lastNumberString appendString:numberString];
        }
        else
        {
            //找到数字组合了
            if ( ![lastNumberString isEqualToString:@""] )
            {
                break;
            }
        }
    }
    
    NSInteger firstNumber = [firstNumberString integerValue];
    NSInteger lastNumber = [lastNumberString integerValue];
    BOOL isNumberStringMayEqual = [WXHongBaoRuleUtility isNumberStringMayEqual:firstNumberString to:lastNumberString];
    
    if ( firstNumber != 0
        && firstNumber > lastNumber
        && lastNumber < 10
        && !isNumberStringMayEqual )
    {
        WXHongBaoTitleInfo *info = [[WXHongBaoTitleInfo alloc] initWithTitle:nil splites:nil];
        info.total = firstNumber;
        info.hit = lastNumber;
        info.vaild = YES;
        
        return info;
    }
    
    return nil;
}

@end
