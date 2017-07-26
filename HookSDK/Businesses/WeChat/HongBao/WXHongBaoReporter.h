//
//  WXHongBaoReporter.h
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXHongBaoReporter : NSObject

+ (instancetype)shareInstance;

- (void)initReporter;

- (NSString *)reportAmountInfoToServer:(NSUInteger)amount
                          appKey:(NSString *)appKey
                     accountName:(NSString *)accountName
                    accountStyle:(NSString *)accountStyle;

@end
