//
//  NSObject(HSClassInfo).m
//  HookSDK
//
//  Created by dps on 17/3/10.
//
//

#import "NSObject+HSClassInfo.h"
#import <objc/runtime.h>
#import "HKCommonDefine.h"

@implementation NSObject (HSClassInfo)

/* 获取对象的所有属性和属性内容 */
- (NSDictionary *)getAllPropertiesAndVaules
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}
/* 获取对象的所有属性 */
- (NSArray *)getAllProperties
{
    u_int count;
    
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return propertiesArray;
}
/* 获取对象的所有方法 */
-(NSArray *)getAllMethods
{
    NSMutableArray *methodList = [[NSMutableArray alloc] init];
    
    unsigned int mothCout_f =0;
    Method* mothList_f = class_copyMethodList([self class],&mothCout_f);
    for(int i=0;i<mothCout_f;i++)
    {
        Method temp_f = mothList_f[i];
        //IMP imp_f = method_getImplementation(temp_f);
        //SEL name_f = method_getName(temp_f);
        const char* name_s =sel_getName(method_getName(temp_f));
        int arguments = method_getNumberOfArguments(temp_f);
        const char* encoding =method_getTypeEncoding(temp_f);
        
        NSString *methodDetail = [NSString stringWithFormat: @"name:%@,param:%d,encode:%@",[NSString stringWithUTF8String:name_s],
              arguments,
              [NSString stringWithUTF8String:encoding]];
        
        [methodList addObject:methodDetail];
    }
    
    free(mothList_f);
    
    return methodList;
}

+ (void)printInstance:(id)obj
{
    if ( obj == nil )
    {
        HKDefaultLog(@"obj is nil");
        return;
    }
    
    if ( ![obj isKindOfClass:[NSObject class]] )
    {
        HKDefaultLog(@"obj is not a object");
        return;
    }
    
    NSDictionary *propertyList = [obj getAllPropertiesAndVaules];
    NSArray *methodList = [obj getAllMethods];
    NSString *ClassLogBegin = [NSString stringWithFormat:@"[ClassBegin]:%@", NSStringFromClass([obj class])];
    NSString *ClassLogEnd = [NSString stringWithFormat:@"[ClassEnd]:%@", NSStringFromClass([obj class])];
    NSString *methodLogBegin = [NSString stringWithFormat:@"[MethodBegin]:%@", NSStringFromClass([obj class])];
    NSString *methodLogEnd = [NSString stringWithFormat:@"[MethodEnd]:%@", NSStringFromClass([obj class])];
    NSString *propertyLogBegin = [NSString stringWithFormat:@"[PropertyBegin]:%@", NSStringFromClass([obj class])];
    NSString *propertyLogEnd = [NSString stringWithFormat:@"[PropertyEnd]:%@", NSStringFromClass([obj class])];
    
    HKDefaultLog(ClassLogBegin);
    
    HKDefaultLog(methodLogBegin);
    HKDefaultLog([methodList description]);
    HKDefaultLog(methodLogEnd);
    
    HKDefaultLog(propertyLogBegin);
    HKDefaultLog([propertyList description]);
    HKDefaultLog(propertyLogEnd);
    
    HKDefaultLog(ClassLogEnd);
}

@end
