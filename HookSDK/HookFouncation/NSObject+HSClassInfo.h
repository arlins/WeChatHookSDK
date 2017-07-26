//
//  NSObject(HSClassInfo).h
//  HookSDK
//
//  Created by dps on 17/3/10.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (HSClassInfo)

/* 获取对象的所有属性和属性内容 */
- (NSDictionary *)getAllPropertiesAndVaules;

/* 获取对象的所有属性 */
- (NSArray *)getAllProperties;

/* 获取对象的所有方法 */
-(NSArray *)getAllMethods;

+ (void)printInstance:(id)obj;

@end
