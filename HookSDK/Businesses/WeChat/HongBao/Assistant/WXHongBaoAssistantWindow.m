//
//  WXHongBaoAssistantWindow.m
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoAssistantWindow.h"
#import "WXHongBaoLogWindow.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "UIColor+HKHexString.h"
#import "WXHongBaoAssistantMenu.h"


@interface WXHongBaoAssistantWindow ()

@property (nonatomic, strong) UIButton *mainButton;

@end

@implementation WXHongBaoAssistantWindow

+ (instancetype)shareInstance
{
    static WXHongBaoAssistantWindow *ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        CGRect frame;
        
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - KWXHongBaoAssistantWindowWidth - 10;
        frame.origin.y = 80;
        frame.size.width = KWXHongBaoAssistantWindowWidth;
        frame.size.height = WXHongBaoAssistantWindowHeight;
        
        ss = [[[self class] alloc] initWithFrame:frame];
        ss.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:ss];
    });
    
    return ss;
}

- (void)show
{
    self.hidden = NO;
}

- (void)switchAssistantStyle
{
    [WXHongBaoAssistantMenu shareInstance].hidden = ![WXHongBaoAssistantMenu shareInstance].hidden;
    
    if ( [WXHongBaoAssistantMenu shareInstance].hidden )
    {
        [WXHongBaoLogWindow shareInstance].hidden = YES;
    }
    
    [self updateButtonState];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        self.mainButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.mainButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.mainButton.titleLabel.textColor = [UIColor whiteColor];
        self.mainButton.backgroundColor = [UIColor colorWithHexString:@"#3ab464"];
        self.mainButton.layer.cornerRadius = frame.size.height / 2.0;
        [self.mainButton addTarget:self action:@selector(onMainButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.mainButton];
        [self createMenu];
        [self updateButtonState];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXHongBaoIPCCmdMgrLogArrived:) name:KWXHongBaoIPCCmdMgrLogArrived object:nil];
    }
    
    return self;
}

- (void)updateButtonState
{
    NSString *title = [WXHongBaoAssistantMenu shareInstance].hidden ? @"展开" : @"收起";
    [self.mainButton setTitle:title forState:UIControlStateNormal];
}

- (void)onMainButtonClick:(id)sender
{
    [self switchAssistantStyle];
}

- (void)createMenu
{
    CGRect frame;
    
    frame.origin.x = [UIScreen mainScreen].bounds.size.width - KWXHongBaoAssistantWindowWidth - 10;
    frame.origin.y = self.frame.origin.y + self.frame.size.height + 20;
    frame.size.width = KWXHongBaoAssistantWindowWidth;
    frame.size.height = 4 * WXHongBaoAssistantWindowHeight + 30;
    
    [WXHongBaoAssistantMenu shareInstance].frame = frame;
    
    [[UIApplication sharedApplication].keyWindow addSubview:[WXHongBaoAssistantMenu shareInstance]];
}

- (void)onWXHongBaoIPCCmdMgrLogArrived:(NSNotification *)n
{
    NSString *log = [n.userInfo objectForKey:KWXHongBaoIPCCmdMgrLogKey];
    [[WXHongBaoLogWindow shareInstance] appendMessage:log];
}

@end
