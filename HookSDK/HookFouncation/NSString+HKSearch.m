//
//  NSString+HKSearch.m
//  HookSDK
//
//  Created by arlin on 17/3/18.
//
//

#import "NSString+HKSearch.h"

@implementation NSString (HKSearch)

- (BOOL)hk_containsString:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    
    return range.location != NSNotFound;
}

@end
