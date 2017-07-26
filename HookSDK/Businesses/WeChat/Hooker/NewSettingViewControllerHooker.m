//
//  NewSettingViewControllerHooker.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "NewSettingViewControllerHooker.h"
#import "WeChatRedEnvelop.h"
#import "WeChatHookSDK.h"
#import "NSObject+HKInstanceVariable.h"
#import "NSObject+HKMethodSwizzed.h"
#import "WXHongBaoSettingViewController.h"
#import "WXHongBaoSettingMgr.h"

@implementation NewSettingViewControllerHooker

- (void)wxhk_reloadTableData
{
    [self wxhk_reloadTableData];
    
    MMTableViewInfo *tableViewInfo = [self instanceObjectVariableOf:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    
    MMTableViewCellInfo *settingCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(setting) target:self title:@"红包助手" accessoryType:1];
    [sectionInfo addCell:settingCell];
    
    [tableViewInfo insertSection:sectionInfo At:0];
    
    MMTableView *tableView = [tableViewInfo getTableView];
    [tableView reloadData];
}

- (void)wxhk_setting {
    WXHongBaoSettingViewController *settingViewController = [[WXHongBaoSettingViewController alloc] init];
    [self.navigationController PushViewController:settingViewController animated:YES];
}

+ (void)hook
{
//    [NSObject hk_hookInstanceMethod:NSClassFromString(@"NewSettingViewControllerHooker") originalClass:NSClassFromString(@"NewSettingViewController") swizzledSelector:@selector(wxhk_reloadTableData) originalSelector:@selector(reloadTableData)];
//    
//    [NSObject hk_hookInstanceMethod:NSClassFromString(@"NewSettingViewControllerHooker") originalClass:NSClassFromString(@"NewSettingViewController") swizzledSelector:@selector(wxhk_setting) originalSelector:@selector(setting)];
// 
//    [NSObject hk_hookInstanceMethod:NSClassFromString(@"NewSettingViewControllerHooker") originalClass:NSClassFromString(@"NewSettingViewController") swizzledSelector:@selector(wxhk_followMyOfficalAccount) originalSelector:@selector(followMyOfficalAccount)];
}


@end
