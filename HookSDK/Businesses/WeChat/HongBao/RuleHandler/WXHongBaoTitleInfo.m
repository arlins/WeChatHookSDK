//
//  WXHongBaoTitleInfo.m
//  HookSDK
//
//  Created by arlin on 17/3/24.
//  Copyright © 2017年 arlin. All rights reserved.
//

#import "WXHongBaoTitleInfo.h"

@implementation WXHongBaoTitleInfo

- (instancetype)initWithTitle:(NSString *)title splites:(NSArray *)splites
{
    self = [super init];
    
    if ( self )
    {
        self.vaild = NO;
        self.total = 0;
        self.total = 0;
        
        for ( NSString * splite in splites )
        {
            NSArray *titleArray = [title componentsSeparatedByString:splite];
            if ( titleArray.count != 2 )
            {
                continue;
            }
            
            NSInteger total = [(NSString *)[titleArray objectAtIndex:0] integerValue];
            NSInteger hit = [(NSString *)[titleArray objectAtIndex:1] integerValue];
            
            if ( total > 0 && hit >= 0 )
            {
                self.vaild = YES;
                self.total = total;
                self.hit = hit;
                break;
            }
        }
    }
    
    return self;
}

@end
