//
//  HookSDK.m
//  HookSDK
//
//  Created by dps on 17/3/10.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "WeChatHookSDK.h"

//#define CYCRIPT_PORT 8888

CHConstructor
{
    @autoreleasepool
    {
        [[WeChatHookSDK shareInstance] hook];
    }
}
