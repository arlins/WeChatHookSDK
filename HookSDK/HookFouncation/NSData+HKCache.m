//
//  NSData+HKCache.m
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "NSData+HKCache.h"

@implementation NSData (HKCache)

+ (id)hk_valueForKey:(NSString *)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void)hk_setValue:(id)value forKey:(NSString *)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

@end
