//
//  NSDictionary+HKURL.m
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import "NSDictionary+HKURL.h"

#define HKURLItemSplite @"&&&"
#define HKURLKeyValueSplite @":::"

@implementation NSDictionary (HKURL)

- (NSString *)toURL
{
    if ( ![self isKindOfClass:[NSDictionary class]] )
    {
        return @"NSDictionary + HKPrint { is not kind of NSDictionary}";
    }
    
    NSMutableString *string = [NSMutableString stringWithFormat:@""];

    for ( id key in self.allKeys )
    {
        id value = [self objectForKey:key];
        
        if ( ![string isEqualToString:@""] )
        {
            [string appendString:HKURLItemSplite];
        }
        
        [string appendString:[NSString stringWithFormat:@"%@%@%@",key, HKURLKeyValueSplite, value]];
    }
    
    return string;
}

+ (instancetype)fromURL:(NSString *)URL
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *items = [URL componentsSeparatedByString:HKURLItemSplite];
    for (NSString *item in items )
    {
        NSArray *itemValue = [item componentsSeparatedByString:HKURLKeyValueSplite];
        if ( itemValue.count != 2 )
        {
            continue;
        }
        
        NSString *key = [itemValue objectAtIndex:0];
        NSString *value = [itemValue objectAtIndex:1];
        
        [dic setObject:key forKey:value];
    }
    
    return dic;
}

@end
