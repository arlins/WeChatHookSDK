//
//  WXHongBaoAssistantMenu.m
//  HookSDK
//
//  Created by dps on 17/3/16.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoAssistantMenu.h"
#import "UIColor+HKHexString.h"
#import "WXHongBaoAssistantWindow.h"
#import "WXHongBaoLogWindow.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "WeChatCommonDefine.h"
#import "WXHongBaoSettingViewController.h"
#import "WXAutoChangeMyInfoMgr.h"

@interface WXHongBaoAssistantMenu ()

@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *activeButton;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation WXHongBaoAssistantMenu

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] initWithFrame:CGRectZero];
    });
    
    return ss;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        self.logButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.logButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.logButton.titleLabel.textColor = [UIColor whiteColor];
        self.logButton.backgroundColor = [UIColor colorWithHexString:@"#278cf1"];
        self.logButton.layer.cornerRadius = KWXHongBaoAssistantWindowWidth / 2.0;
        [self.logButton addTarget:self action:@selector(onLogButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.logButton];
        
        self.switchButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.switchButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.switchButton.titleLabel.textColor = [UIColor whiteColor];
        self.switchButton.backgroundColor = [UIColor colorWithHexString:@"#278cf1"];
        self.switchButton.layer.cornerRadius = KWXHongBaoAssistantWindowWidth / 2.0;
        [self.switchButton addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.switchButton];
        
        self.activeButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.activeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.activeButton.titleLabel.textColor = [UIColor whiteColor];
        self.activeButton.backgroundColor = [UIColor colorWithHexString:@"#278cf1"];
        self.activeButton.layer.cornerRadius = KWXHongBaoAssistantWindowWidth / 2.0;
        [self.activeButton addTarget:self action:@selector(onActiveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.activeButton];
        
        self.settingButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.settingButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.settingButton.titleLabel.textColor = [UIColor whiteColor];
        self.settingButton.backgroundColor = [UIColor colorWithHexString:@"#278cf1"];
        self.settingButton.layer.cornerRadius = KWXHongBaoAssistantWindowWidth / 2.0;
        [self.settingButton addTarget:self action:@selector(onSettingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.settingButton];
        
        [self layoutSubviews];
        [self updateButtonState];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXHongBaoSettingUpdate) name:KWXHongBaoSettingUpdate object:nil];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = KWXHongBaoAssistantWindowWidth;
    frame.size.height = WXHongBaoAssistantWindowHeight;
    self.logButton.frame = frame;
    
    frame.origin.x = 0;
    frame.origin.y = frame.origin.y + frame.size.height + 10;
    frame.size.width = KWXHongBaoAssistantWindowWidth;
    frame.size.height = WXHongBaoAssistantWindowHeight;
    self.switchButton.frame = frame;
    
    frame.origin.x = 0;
    frame.origin.y = frame.origin.y + frame.size.height + 10;
    frame.size.width = KWXHongBaoAssistantWindowWidth;
    frame.size.height = WXHongBaoAssistantWindowHeight;
    self.activeButton.frame = frame;
    
    frame.origin.x = 0;
    frame.origin.y = frame.origin.y + frame.size.height + 10;
    frame.size.width = KWXHongBaoAssistantWindowWidth;
    frame.size.height = WXHongBaoAssistantWindowHeight;
    self.settingButton.frame = frame;
}

- (void)onLogButtonClick:(id)sender
{
    [WXHongBaoLogWindow shareInstance].hidden = ![WXHongBaoLogWindow shareInstance].hidden;
}

- (void)onSwitchButtonClick:(id)sender
{
    WXHongBaoSettingInfoItem *info = [[WXHongBaoSettingMgr shareInstance] settingInfoByKey:KWXHongBaoSettingKeyEnable];
    
    info.switchOn = !info.switchOn;
    
    [[WXHongBaoSettingMgr shareInstance] updateSettingInfo:info];
}

- (void)onActiveButtonClick:(id)sender
{
//    [[WXHongBaoIPCCmdMgr shareInstance] sendActiveCmd:KWeChatTwoURLSchema duration:3.0 backToApp:KWeChatOneURLSchema];
    [[WXHongBaoIPCCmdMgr shareInstance] sendKeepAliveCmd];
}

- (void)updateButtonState
{
    [self.activeButton setTitle:@"激活" forState:UIControlStateNormal];
    [self.logButton setTitle:@"日志" forState:UIControlStateNormal];
    [self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    
    BOOL isOpened = [[WXHongBaoSettingMgr shareInstance] isEnable];
    [self.switchButton setTitle:isOpened ? @"关闭" : @"开启" forState:UIControlStateNormal];
}

- (void)onWXHongBaoSettingUpdate
{
    [self updateButtonState];
}

- (void)onSettingButtonClick:(id)sender
{
    [[WXHongBaoAssistantWindow shareInstance] switchAssistantStyle];
    [WXHongBaoSettingViewController show];
}

@end
