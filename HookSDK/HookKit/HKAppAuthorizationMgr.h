//
//  HKAppAuthorizationMgr.h
//  HookSDK
//
//  Created by arlin on 17/3/17.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAppAuthorizationMgr : NSObject

@property (nonatomic, copy) NSString *settingURL;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSArray *appKeysList;
@property (nonatomic, strong) NSArray *blackKeysList;

+ (instancetype)shareInstance;

- (void)startFetchData;

- (void)makeAppAuthorization:(NSString *)appKey;

- (BOOL)isAppAuthorized;

- (NSString *)appKey;

@end
