//
//  ViewController.h
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXHongBaoSettingMgr.h"

#define WXHongBaoSettingCellTitleHeight 50

@class WXHongBaoSettingCell;

@protocol WXHongBaoSettingCellDelegate <NSObject>

@required
- (void)wxHongBaoSettingCell:(WXHongBaoSettingCell *)cell switchChanged:(BOOL)on;

@end

@interface WXHongBaoSettingCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, weak) id<WXHongBaoSettingCellDelegate> delegate;

@property (nonatomic, assign) BOOL enableHighlight;
@property (nonatomic, strong) UILabel *titleContentLabel;
@property (nonatomic, strong) UISwitch *switchControl;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) id userInfo;

@end


@interface WXHongBaoSettingViewController : UITableViewController

+ (void)show;
- (void)dismiss;

@end

