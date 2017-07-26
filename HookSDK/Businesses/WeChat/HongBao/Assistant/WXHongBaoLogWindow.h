//
//  WXHongBaoLogWindow.h
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXHongBaoLogWindow : UIView

+ (instancetype)shareInstance;

- (void)appendMessage:(NSString *)message;

@end
