//
//  WXHookTicktockTask
//  555
//
//  Created by dps on 17/3/14.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HKTicktockTaskBlock)(void);

@interface HKTicktockTask : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL repeat;

@property (nonatomic, strong) HKTicktockTaskBlock taskBlock;

- (void)start;
- (void)stop;

@end
