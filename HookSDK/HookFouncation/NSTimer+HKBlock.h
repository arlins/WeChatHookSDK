//
//  HKTimer.h
//  HookSDK
//
//  Created by arlin on 17/4/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HKTimeoutBlock)(NSInteger tag);

@interface HKTimeoutInfo : NSObject

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, copy) HKTimeoutBlock block;

@end

// ------------ NSTimer ------------

@interface NSTimer (HKBlock)

+ (NSTimer *)startWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)isRepeat timeout:(void(^)())timeout;
+ (NSTimer *)startWithTimeInterval:(NSTimeInterval)interval timeoutInfo:(HKTimeoutInfo *)info repeats:(BOOL)isRepeat;

@end
