//
//  HKAppearViewController.h
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HKAppearBlock)(BOOL);
typedef void(^HKViewDidLoadBlock)();

@interface HKAppearViewController : UIViewController

@property (nonatomic, strong) HKViewDidLoadBlock viewDidLoadBlock;
@property (nonatomic, strong) HKAppearBlock willAppear;
@property (nonatomic, strong) HKAppearBlock didAppear;
@property (nonatomic, strong) HKAppearBlock willDisappear;
@property (nonatomic, strong) HKAppearBlock disDisappear;

@end
