//
//  WXHongBaoHitConfigViewController
//  HookSDK
//
//  Created by dps on 17/3/21.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoSmartOpenConfigViewController.h"
#import "WXHongBaoSettingViewController.h"
#import "HKAlertView.h"
#import "WXHongBaoRuleManager.h"
#import "WXHongBaoRuleHandler.h"

@interface WXHongBaoSmartOpenConfigViewController () <UITableViewDataSource, UITableViewDelegate, WXHongBaoSettingCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WXHongBaoSmartOpenConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"智能比例抢红包";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[WXHongBaoSettingCell class] forCellReuseIdentifier:@"WXHongBaoSettingCell"];
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXHongBaoRuleConfigUpdate) name:KWXHongBaoRuleConfigUpdate object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self settingInfoList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXHongBaoSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WXHongBaoSettingCell"];
    WXHongBaoSettingInfoItem *info = [[self settingInfoList] objectAtIndex:indexPath.row];
    
    cell.userInfo = info;
    cell.titleContentLabel.text = info.title;
    cell.switchControl.hidden = !info.switchShow;
    cell.switchControl.on = info.switchOn;
    cell.delegate = self;
    
    if ( info.text != nil )
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.enableHighlight = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return WXHongBaoSettingCellTitleHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXHongBaoSettingInfoItem *info = [[self settingInfoList] objectAtIndex:indexPath.row];
    if ( info.text != nil )
    {
        
        HKAlertView *alert = [[HKAlertView alloc] initWithTitle:@"设置" message:info.title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.text = info.text;
        alert.userInfo = info;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 && [alertView isKindOfClass:[HKAlertView class]] )
    {
        HKAlertView *hkAlertView = (HKAlertView *)alertView;
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        WXHongBaoSettingInfoItem *info = hkAlertView.userInfo;
        
        info.text = text;
        
        WXHongBaoRuleHandler *handler = [[WXHongBaoRuleManager shareInstance] ruleHandlerOfStyle:WXHongBaoRuleStyleSmartOpen] ;
        [handler updateRuleConfig:info];
    }
}

- (void)wxHongBaoSettingCell:(WXHongBaoSettingCell *)cell switchChanged:(BOOL)on
{
    WXHongBaoSettingInfoItem *info = cell.userInfo;
    info.switchOn = on;
    
    WXHongBaoRuleHandler *handler = [[WXHongBaoRuleManager shareInstance] ruleHandlerOfStyle:WXHongBaoRuleStyleSmartOpen] ;
    [handler updateRuleConfig:info];
}

- (void)onWXHongBaoRuleConfigUpdate
{
    [self.tableView reloadData];
}

- (NSArray *)settingInfoList
{
    WXHongBaoRuleHandler *handler = [[WXHongBaoRuleManager shareInstance] ruleHandlerOfStyle:WXHongBaoRuleStyleSmartOpen] ;
    
    return handler.config;
}

@end
