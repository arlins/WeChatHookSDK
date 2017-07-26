//
//  WXBongBaoLogButton.h
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KWXHongBaoAssistantWindowWidth 40
#define WXHongBaoAssistantWindowHeight 40

@interface WXHongBaoAssistantWindow : UIView

+ (instancetype)shareInstance;

- (void)show;
- (void)switchAssistantStyle;

@end
