//
//  WXHongBaoSettingTextViewController.m
//  HookSDK
//
//  Created by dps on 17/3/16.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoSettingTextViewController.h"

#define KWXHongBaoSettingTextViewControllerSpace 10

@interface WXHongBaoSettingTextViewController ()

@end

@implementation WXHongBaoSettingTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect frame;
        frame.origin.x = KWXHongBaoSettingTextViewControllerSpace;
        frame.origin.y = 80;
        frame.size.width = self.view.bounds.size.width - 2*KWXHongBaoSettingTextViewControllerSpace;
        frame.size.height = 100;
        
        self.textView = [[UITextView alloc] init];
        self.textView.frame = frame;
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.textColor = [UIColor blackColor];
        self.textView.font = [UIFont systemFontOfSize:13.0];
        self.textView.layer.borderWidth = 0.5;
        self.textView.layer.borderColor = [UIColor grayColor].CGColor;
        self.textView.layer.cornerRadius = 4.0;
        
        [self.view addSubview:self.textView];
    }
    
    return self;
}

@end
