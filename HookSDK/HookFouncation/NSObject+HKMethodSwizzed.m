//
//  NSObject+MethodSwizzed.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "NSObject+HKMethodSwizzed.h"
#import <objc/runtime.h>

@implementation NSObject (HKMethodSwizzed)

+ (void)hk_swizzedInstanceMethod:(SEL) swizzledSelector originalSelector:(SEL)originalSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)hk_swizzedInstanceMethod:(Class)className swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = className;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)hk_hookInstanceMethod:(Class)swizzledClass originalClass:(Class)originalClass swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);

    class_addMethod(originalClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));

    class_replaceMethod(originalClass,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
}

@end
