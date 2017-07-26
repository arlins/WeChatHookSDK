//
//  WXHongBaoSettingMgr.h
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXHongBaoTitleInfo.h"

@interface WXHongBaoSettingInfoItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL switchShow;
@property (nonatomic, assign) BOOL switchOn;

@end

extern NSString *const KWXHongBaoSettingUpdate;

extern NSString *const KWXHongBaoSettingKeyEnable;
extern NSString *const KWXHongBaoSettingKeyNotice;
extern NSString *const KWXHongBaoSettingKeyAutoOpen;
extern NSString *const KWXHongBaoSettingKeyAutoOpenDelay;
extern NSString *const KWXHongBaoSettingKeyTitle;
extern NSString *const KWXHongBaoSettingKeyGroupName;
extern NSString *const KWXHongBaoSettingKeyQueryDelay;
extern NSString *const KWXHongBaoSettingKeySmartSpliteTitle;
extern NSString *const KWXHongBaoSettingKeyAuth;
extern NSString *const KWXHongBaoSettingKeyIsMaster;
extern NSString *const KWXHongBaoSettingKeyHit;
extern NSString *const KWXHongBaoSettingKeySmall;
extern NSString *const KWXHongBaoSettingKeyMasterIP;
extern NSString *const KWXHongBaoSettingKeySmartOpen;

@interface WXHongBaoSettingMgr : NSObject

@property (nonatomic, strong) NSArray<WXHongBaoSettingInfoItem *> *settingInfoList;

+ (instancetype)shareInstance;

- (void)updateSettingInfo:(WXHongBaoSettingInfoItem *)info;
- (void)clearLocalData;

- (WXHongBaoSettingInfoItem *)settingInfoByKey:(NSString *)key;

- (float)openDelay;
- (float)queryDelay;
- (BOOL)isEnable;
- (BOOL)canNotice;
- (BOOL)autoOpen;
- (BOOL)isGroupNameVaild:(NSString *)groupName;
- (BOOL)isMaster;
- (BOOL)isAppAuthorized;
- (BOOL)canQuickOpen;
- (BOOL)enableFullLog;
- (BOOL)autoChangeInfo;
- (BOOL)openOnlySendByMe;

- (NSString *)masterIPAddress;

- (NSString *)makeupConfigString;
- (void)configByConfigString:(NSString *)conf;

@end
