//
//  NSData+HKCache.h
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HKCache)

+ (id)hk_valueForKey:(NSString *)key;
+ (void)hk_setValue:(id)value forKey:(NSString *)key;

@end
