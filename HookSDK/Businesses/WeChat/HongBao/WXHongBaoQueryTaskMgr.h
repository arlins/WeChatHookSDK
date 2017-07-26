//
//  WXHookQueryTaskMgr.h
//  555
//
//  Created by dps on 17/3/14.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeChatRedEnvelop.h"

@interface WXHongBaoQueryTaskMgr : NSObject

+ (instancetype)shareInstance;

- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap;
- (void)stopQueryHongBaoDetailTask:(CMessageWrap *)wrap;
- (BOOL)isRunningQueryTaskOf:(CMessageWrap *)wrap;

- (void)startQueryHongBaoStateTask:(NSString *)nativeURL;
- (void)stopQueryHongBaoStateTask:(NSString *)nativeURL;
- (BOOL)isRunningQueryStateTaskOf:(NSString *)nativeURL;

@end
