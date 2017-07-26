//
//  NSObject+MethodSwizzed.h
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (HKMethodSwizzed)

+ (void)hk_swizzedInstanceMethod:(Class)className swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector;


+ (void)hk_hookInstanceMethod:(Class)swizzledClass originalClass:(Class)originalClass swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector;

@end
