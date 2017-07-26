//
//  HKAsynTickoutTask.h
//  HookSDK
//
//  Created by arlin on 17/4/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKAsynTickoutTask;

typedef void(^HKAsynTicktockTaskBlock)(HKAsynTickoutTask *);

@interface HKAsynTickoutTask : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) int repeatCount;

@property (nonatomic, strong) HKAsynTicktockTaskBlock taskBlock;

- (void)start;
- (void)stop;

@end
