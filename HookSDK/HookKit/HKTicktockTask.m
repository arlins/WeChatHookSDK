//
//  WXHookTicktockTask
//  555
//
//  Created by dps on 17/3/14.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "HKTicktockTask.h"

@interface HKTicktockTask ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HKTicktockTask

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.repeat = YES;
    }
    
    return self;
}

- (void)startTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(onTimerTimeout:) userInfo:nil repeats:self.repeat];
}

- (void)stopTimer
{
    if ( self.timer )
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onTimerTimeout:(id)sender
{
    [self makeAction];
}

- (void)start
{
    [self startTimer];
}

- (void)stop
{
    [self stopTimer];
}

- (void)makeAction
{
    if ( self.taskBlock )
    {
        self.taskBlock();
    }
}

@end
