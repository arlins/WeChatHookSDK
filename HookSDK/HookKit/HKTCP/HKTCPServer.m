//
//  HKTCPServer.m
//  HookSDK
//
//  Created by arlin on 17/3/19.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "HKTCPServer.h"
#import "GCDAsyncSocket.h"

@interface HKTCPServer () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableArray *connectedSockets;
@property (nonatomic, assign) NSInteger preferredSocketIndex;
@end

@implementation HKTCPServer

- (void)start:(NSUInteger)port
{
    NSError  *error = [[NSError alloc] init];
    self.preferredSocketIndex = -1;
    self.connectedSockets = [NSMutableArray array];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket acceptOnPort:port error:&error];
}

- (void)stop
{
    _socket = nil;
    _connectedSockets = nil;
}

- (void)sendDataToAllClient:(NSString *)data
{
    for ( GCDAsyncSocket *conn in self.connectedSockets )
    {
        NSData *nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
        [conn writeData:nsData withTimeout:-1 tag:0];
    }
}

- (void)sendDataToPreferredClient:(NSString *)data
{
    if ( self.connectedSockets.count == 0 )
    {
        return;
    }
    
    self.preferredSocketIndex ++;
    
    if ( self.preferredSocketIndex >= self.connectedSockets.count )
    {
        self.preferredSocketIndex = 0;
    }
    
    GCDAsyncSocket *conn = [self.connectedSockets objectAtIndex:self.preferredSocketIndex];
    NSData *nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [conn writeData:nsData withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
{
    NSLog(@"[Server] New connection.");
    [self.connectedSockets addObject:newSocket];
    [self.delegate onServerSocketConntcted];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
    [self.connectedSockets removeObject:socket];
    [self.delegate onServerSocketDisconnected];
    NSLog(@"[Server] Closed connection: %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Server] Received: %@", text);
    
    [sock readDataWithTimeout:-1 tag:0];
    
    [self.delegate onServerDataArrived:text];
}

- (GCDAsyncSocket *)currentConnSocket
{
    if ( self.connectedSockets.count == 0 )
    {
        return nil;
    }
    
    return [self.connectedSockets firstObject];
}

@end
