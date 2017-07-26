//
//  HKTCPServer.h
//  HookSDK
//
//  Created by arlin on 17/3/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HKTCPServerDelegate <NSObject>

@required
- (void)onServerDataArrived:(NSString *)data;
- (void)onServerSocketDisconnected;
- (void)onServerSocketConntcted;

@end

@interface HKTCPServer : NSObject

@property (nonatomic, weak) id<HKTCPServerDelegate> delegate;

- (void)start:(NSUInteger)port;
- (void)stop;

- (void)sendDataToAllClient:(NSString *)data;
- (void)sendDataToPreferredClient:(NSString *)data;

@end
