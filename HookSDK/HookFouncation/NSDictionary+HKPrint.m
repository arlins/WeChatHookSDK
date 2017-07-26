//
//  NSDictionary+HKPrint.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "NSDictionary+HKPrint.h"

@implementation NSDictionary(HKPrint)

- (NSString *)outputAllKeysAndValues
{
    if ( ![self isKindOfClass:[NSDictionary class]] )
    {
        return @"NSDictionary + HKPrint { is not kind of NSDictionary}";
    }
    
    NSMutableString *string = [NSMutableString string];
    
    [string appendString:@"NSDictionary + HKPrint {"];
    for ( id key in self.allKeys )
    {
        id value = [self objectForKey:key];
        
        [string appendString:[NSString stringWithFormat:@"\n[%@]%@ : [%@]%@",[key class], key,[value class], value]];
    }
    
    [string appendString:@"\n}\n"];
    
    return string;
}

@end
