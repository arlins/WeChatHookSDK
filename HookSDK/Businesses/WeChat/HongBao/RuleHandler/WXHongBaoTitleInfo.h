//
//  WXHongBaoTitleInfo.h
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXHongBaoTitleInfo : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger hit;
@property (nonatomic, assign) BOOL vaild;

- (instancetype)initWithTitle:(NSString *)title splites:(NSArray *)splites;

@end
