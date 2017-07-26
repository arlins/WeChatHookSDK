//
//  HKTCPClient.h
//  HookSDK
//
//  Created by arlin on 17/3/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HKTCPClientDelegate <NSObject>

@required
- (void)onClientDataArrived:(NSString *)data;
- (void)onClientSocketDisconnected;
- (void)onClientSocketConntcted;

@end

@interface HKTCPClient : NSObject

@property (nonatomic, weak) id<HKTCPClientDelegate> delegate;

- (void)connect:(NSString *)host port:(NSUInteger)port;
- (void)disconnect;

- (void)send:(NSString *)data;

@end
