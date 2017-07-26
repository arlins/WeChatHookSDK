//
//  NSObject+HKInstanceVariable.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "NSObject+HKInstanceVariable.h"
#import <objc/runtime.h>

@implementation NSObject (HKInstanceVariable)

- (id)instanceObjectVariableOf:(NSString *)name
{
    Class class = [self class];
    Ivar nameIvar = class_getInstanceVariable(class, [name UTF8String] );
    return object_getIvar(self, nameIvar);
}

@end
