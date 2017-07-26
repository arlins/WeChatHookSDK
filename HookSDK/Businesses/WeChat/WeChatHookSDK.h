//
//  WeChatHookSDK.h
//  HookSDK
//
//  Created by dps on 17/3/10.
//
//

#import <Foundation/Foundation.h>
#import "HKCommonDefine.h"
#import "WeChatCommonDefine.h"

@interface WeChatHookSDK : NSObject

+ (instancetype)shareInstance;

- (void)hook;

@end
