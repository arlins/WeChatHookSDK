//
//  HKCommonDefine.h
//  HookSDK
//
//  Created by dps on 17/3/10.
//
//

#import <Foundation/Foundation.h>

#define HKAppBundleId [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define HKTagNSLog(tag,string) NSLog(@"[%@] [HookSDK] [%@] %@", HKAppBundleId, tag, string);
#define HKDefaultLog(string) HKTagNSLog(@"DefaultHook", string)

#define HKObjectPerformSelector(obj, selector, type, value) { \
if ([obj respondsToSelector:selector]) \
{ \
NSMethodSignature* sig = [obj methodSignatureForSelector:selector]; \
NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig]; \
[invo setTarget:obj]; \
[invo setSelector:selector]; \
[invo invoke]; \
\
if (!strcmp([sig methodReturnType], @encode(type))) \
{ \
[invo getReturnValue:&value]; \
} \
\
} \
}

#define HKGetObjectValue( obj_class, name, obj, type, value)  { \
Ivar varVaule = class_getInstanceVariable(objc_getClass(obj_class), name); \
ptrdiff_t offset = ivar_getOffset(varVaule); \
unsigned char *stuffBytes = (unsigned char *)(__bridge void *)obj; \
value = * ((type *)(stuffBytes + offset)); \
}
