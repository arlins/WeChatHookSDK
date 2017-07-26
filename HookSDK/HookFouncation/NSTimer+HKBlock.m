//
//  HKTimer.m
//  HookSDK
//
//  Created by arlin on 17/4/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "NSTimer+HKBlock.h"

@implementation HKTimeoutInfo

@end

@implementation NSTimer (HKBlock)

#pragma mark Public

+ (NSTimer *)startWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)isRepeat timeout:(void(^)())timeout
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(onTimeoutBlockInvoked:)
                                       userInfo:[timeout copy]
                                        repeats:isRepeat];
}

+ (NSTimer *)startWithTimeInterval:(NSTimeInterval)interval timeoutInfo:(HKTimeoutInfo *)info repeats:(BOOL)isRepeat
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(onTimeout:)
                                       userInfo:info
                                        repeats:isRepeat];
}

#pragma mark Private

+ (void)onTimeoutBlockInvoked:(NSTimer *)timer
{
    void (^timeoutBlock)() = timer.userInfo;
    if (timeoutBlock != nil) {
        timeoutBlock();
    }
}

+ (void)onTimeout:(NSTimer *)timer
{
    HKTimeoutInfo *info = timer.userInfo;
    if (info.block != nil) {
        info.block(info.tag);
    }
}

@end

