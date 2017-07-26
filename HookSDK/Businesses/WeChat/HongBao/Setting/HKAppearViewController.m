//
//  HKAppearViewController.m
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "HKAppearViewController.h"

@interface HKAppearViewController ()

@end

@implementation HKAppearViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( self.viewDidLoadBlock )
    {
        self.viewDidLoadBlock();
    }
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( self.didAppear )
    {
        self.didAppear( animated );
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.willAppear )
    {
        self.willAppear( animated );
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ( self.willDisappear )
    {
        self.willDisappear( animated );
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ( self.disDisappear )
    {
        self.disDisappear( animated );
    }
}
@end
