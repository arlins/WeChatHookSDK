//
//  HKAsynTickoutTask.m
//  HookSDK
//
//  Created by arlin on 17/4/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "HKAsynTickoutTask.h"
#import "NSTimer+HKBlock.h"

@interface HKAsynTickoutTask ()

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isCanceled;

@end

@implementation HKAsynTickoutTask

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.isCanceled = NO;
    }
    
    return self;
}

- (void)start
{
    if ( self.thread != nil )
    {
        return;
    }
    
    NSLog(@"asyn task start %@",self.name);
    self.isCanceled = NO;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadWork) object:nil];
    [self.thread start];
}

- (void)stop
{
    NSLog(@"asyn task stop %@",self.name);
    self.isCanceled = YES;
    [self.thread cancel];
    self.thread = nil;
}

- (void)threadWork
{
    @autoreleasepool {
        [[NSThread currentThread] setName:self.name];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        self.timer = [NSTimer startWithTimeInterval:self.duration repeats:self.repeat timeout:^{
            if ( self.taskBlock && !self.isCanceled )
            {
                self.repeatCount ++;
                if ( self.repeatCount > 9999999 )
                {
                    self.repeatCount = 0;
                }
                
                self.taskBlock( self );
            }
        }];
        
        while ( !self.isCanceled )
        {
            @autoreleasepool {
                [runLoop runUntilDate:[NSDate distantFuture]];
            }
        }
        
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
