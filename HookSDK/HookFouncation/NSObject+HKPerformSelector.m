//
//  NSObject+HKPerformSelector.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "NSObject+HKPerformSelector.h"

@implementation NSObject (HKPerformSelector)

//- (id)objectPerformSelector:(SEL)selector
//{
//    return [self performSelector:selector];
//}
//
//- (id)objectPerformSelector:(SEL)sel arg1:(id)arg1
//{
//    return [self performSelector:sel withObject:arg1];
//}
//
//- (double)doublePerformSelector:(SEL)selector
//{
//    double value = 0.0;
//    if ([self respondsToSelector:selector])
//    {
//        NSMethodSignature* sig = [self methodSignatureForSelector:selector];
//        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
//        [invo setTarget:self];
//        [invo setSelector:selector];
//        [invo invoke];
//        
//        // 返回类型为double
//        if (!strcmp([sig methodReturnType], @encode(double)))
//        {
//            double result = 0;
//            [invo getReturnValue:&value];
//            value = result;
//        }
//    }
//    
//    return value;
//}
//
//- (float)floatPerformSelector:(SEL)selector
//{
//    float value = 0.0;
//    if ([self respondsToSelector:selector])
//    {
//        NSMethodSignature* sig = [self methodSignatureForSelector:selector];
//        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
//        [invo setTarget:self];
//        [invo setSelector:selector];
//        [invo invoke];
//        
//        if (!strcmp([sig methodReturnType], @encode(float)))
//        {
//            [invo getReturnValue:&value];
//        }
//    }
//    
//    return value;
//}
//
//- (int)intPerformSelector:(SEL)selector
//{
//    int value = 0.0;
//    if ([self respondsToSelector:selector])
//    {
//        NSMethodSignature* sig = [self methodSignatureForSelector:selector];
//        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
//        [invo setTarget:self];
//        [invo setSelector:selector];
//        [invo invoke];
//        
//        if (!strcmp([sig methodReturnType], @encode(int)))
//        {
//            [invo getReturnValue:&value];
//        }
//    }
//    
//    return value;
//}

//- (unsigned long)unsignedlongPerformSelector:(SEL)sel
//{
//    
//}
//
//- (long long)longlongPerformSelector:(SEL)sel
//{
//    
//}

@end
