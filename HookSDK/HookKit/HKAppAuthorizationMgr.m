//
//  HKServerConfigureMgr.m
//  HookSDK
//
//  Created by arlin on 17/3/17.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "HKAppAuthorizationMgr.h"
#import "HKHttpDownloader.h"
#import "HKHttpDownloadCache.h"
#import "JSONKit.h"

NSString *const KHKAppAuthorizationKey = @"KHKAppAuthorizationKey";
NSString *const KHKAppAuthorizationStringKey = @"KHKAppAuthorizationStringKey";

@interface HKAppAuthorizationMgr () <HKHttpDownloaderDelegate>

@property (nonatomic, strong) HKHttpDownloader *downloader;

@end

@implementation HKAppAuthorizationMgr

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        
    }
    
    return self;
}

- (void)startFetchData
{
    HKHttpDownloadInfoItem *downloadInfo = [[HKHttpDownloadInfoItem alloc] init];
    downloadInfo.tid = @"1";
    downloadInfo.url = self.settingURL;
    downloadInfo.filePath = [NSString stringWithFormat:@"%@/%@", [[HKHttpDownloadCache defalutCache] defaultCachePath], self.fileName];
    
    self.downloader = [[HKHttpDownloader alloc] init];
    self.downloader.downloadInfo = downloadInfo;
    self.downloader.delegate =self;
    
    [self.downloader start];
}

- (void)hk_HttpDownloadStarted:(HKHttpDownloader *)downloader
{
    
}

- (void)hk_HttpDownloadProcess:(HKHttpDownloader *)downloader process:(float)process
{
    
}

- (void)hk_HttpDownloadStoped:(HKHttpDownloader *)downloader success:(BOOL)success
{
    if ( !success )
    {
        return;
    }
    
    NSData *content = [[NSData alloc] initWithContentsOfFile:downloader.downloadInfo.filePath];
    NSString *contentString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [contentString objectFromJSONString];
    NSString *appKeysString = [json objectForKey:@"app_keys"];
    NSString *blackListKeysString = [json objectForKey:@"black_list_keys"];
    self.appKeysList = [appKeysString componentsSeparatedByString:@","];
    self.blackKeysList = [blackListKeysString componentsSeparatedByString:@","];
}

- (void)makeAppAuthorization:(NSString *)appKey
{
    NSString *fixAppKey = [appKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:fixAppKey forKey:KHKAppAuthorizationStringKey];
    for ( NSString *item in self.appKeysList )
    {
        if ( [fixAppKey isEqualToString:item] )
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:KHKAppAuthorizationKey];
            break;
        }
    }
}

- (BOOL)isAppAuthorized
{
//    NSString *appKey = [self appKey];
//    for ( NSString *item in self.blackKeysList )
//    {
//        if ( [appKey isEqualToString:item] )
//        {
//            return NO;
//        }
//    }
//    
//    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:KHKAppAuthorizationKey];
//    return [value isEqualToString:@"1"];
    
    //授权
    return YES;
}

- (NSString *)appKey
{
    NSString *appKey = [[NSUserDefaults standardUserDefaults] objectForKey:KHKAppAuthorizationStringKey];
    return appKey;
}

@end
