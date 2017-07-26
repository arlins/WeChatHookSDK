//
//  WXAutoChangeMyInfoMgr.h
//  HookSDK
//
//  Created by arlin on 17/4/4.
//
//

#import <Foundation/Foundation.h>

@interface WXAutoChangeMyInfoMgr : NSObject

+ (instancetype)shareInstance;

- (void)start;
- (void)stop;

@end
