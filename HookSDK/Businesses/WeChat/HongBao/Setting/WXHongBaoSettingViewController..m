//
//  ViewController.m
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoSettingViewController.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoHitConfigViewController.h"
#import "HKAlertView.h"
#import "WXHongBaoSmallConfigViewController.h"
#import "UIApplication+TopViewController.h"
#import "WXHongBaoSmartOpenConfigViewController.h"

#define WXHongBaoSettingCellSwitchWidth 50
#define WXHongBaoSettingCellTextViewHeight 80
#define WXHongBaoSettingCellItemSpace 10
#define WXHongBaoSettingCellSpace 20

@implementation WXHongBaoSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        self.enableHighlight = NO;
        self.titleContentLabel = [[UILabel alloc] init];
        self.switchControl = [[UISwitch alloc] init];
        
        self.textLabel.font = [UIFont systemFontOfSize:11.0];
        self.titleContentLabel.textColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.titleContentLabel];
        [self.contentView addSubview:self.switchControl];
        
        [self.switchControl addTarget:self action:@selector(onSwitchControlChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect frame;
    
    frame.origin.x = WXHongBaoSettingCellSpace;
    frame.origin.y = 0;
    frame.size.width = self.contentView.frame.size.width;
    frame.size.height = WXHongBaoSettingCellTitleHeight;
    self.titleContentLabel.frame = frame;
    
    frame.origin.x = self.contentView.frame.size.width - WXHongBaoSettingCellSwitchWidth - WXHongBaoSettingCellSpace;
    frame.origin.y = 8;
    frame.size.width = WXHongBaoSettingCellSwitchWidth;
    frame.size.height = WXHongBaoSettingCellTitleHeight;
    self.switchControl.frame = frame;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if ( self.enableHighlight )
    {
        [super setHighlighted:highlighted];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if ( self.enableHighlight )
    {
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setSelected:(BOOL)selected
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

- (void)onSwitchControlChange:(id)sender
{
    [self.delegate wxHongBaoSettingCell:self switchChanged:self.switchControl.isOn];
}

- (void)onOpenDetailButtonClick:(id)sender
{
    
}

@end



@interface WXHongBaoSettingViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, WXHongBaoSettingCellDelegate>

@end

@implementation WXHongBaoSettingViewController

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"红包助手";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[WXHongBaoSettingCell class] forCellReuseIdentifier:@"WXHongBaoSettingCell"];
    
    UIBarButtonItem * button = [[UIBarButtonItem alloc]initWithTitle:@"清除" style:UIBarButtonItemStyleDone target:self action:@selector(onClearDataButtonClick)];
    button.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = button;
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(onCloseDataButtonClick:)];
    button.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXHongBaoSettingMgrSettingUpdate) name:KWXHongBaoSettingUpdate object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [WXHongBaoSettingMgr shareInstance].settingInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXHongBaoSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WXHongBaoSettingCell"];
    NSArray *settingInfoList = [WXHongBaoSettingMgr shareInstance].settingInfoList;
    WXHongBaoSettingInfoItem *info = [settingInfoList objectAtIndex:indexPath.row];
    
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
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.enableHighlight = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return WXHongBaoSettingCellTitleHeight;
}

- (void)onWXHongBaoSettingMgrSettingUpdate
{
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *settingInfoList = [WXHongBaoSettingMgr shareInstance].settingInfoList;
    WXHongBaoSettingInfoItem *info = [settingInfoList objectAtIndex:indexPath.row];
    if ( info.text == nil )
    {
        return;
    }
    
    if ( [info.name isEqualToString:KWXHongBaoSettingKeyAutoOpenDelay]
        || [info.name isEqualToString:KWXHongBaoSettingKeyQueryDelay]
        || [info.name isEqualToString:KWXHongBaoSettingKeyMasterIP]
        || [info.name isEqualToString:KWXHongBaoSettingKeyAuth]
        || [info.name isEqualToString:KWXHongBaoSettingKeyGroupName] )
    {
        HKAlertView *alert = [[HKAlertView alloc] initWithTitle:@"设置" message:info.title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *txtName = [alert textFieldAtIndex:0];
        txtName.text = info.text;
        alert.userInfo = info;
        [alert show];
    }
    else
    {
        if ( [info.name isEqualToString:KWXHongBaoSettingKeyHit] )
        {
            WXHongBaoHitConfigViewController *vc = [[WXHongBaoHitConfigViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if ( [info.name isEqualToString:KWXHongBaoSettingKeySmall] )
        {
            WXHongBaoSmallConfigViewController *vc = [[WXHongBaoSmallConfigViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if ( [info.name isEqualToString:KWXHongBaoSettingKeySmartOpen] )
        {
            WXHongBaoSmartOpenConfigViewController *vc = [[WXHongBaoSmartOpenConfigViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)onClearDataButtonClick
{
    [[WXHongBaoSettingMgr shareInstance] clearLocalData];
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
        
        [[WXHongBaoSettingMgr shareInstance] updateSettingInfo:info];
    }
}

- (void)wxHongBaoSettingCell:(WXHongBaoSettingCell *)cell switchChanged:(BOOL)on
{
    WXHongBaoSettingInfoItem *item = cell.userInfo;
    item.switchOn = on;
    
    [[WXHongBaoSettingMgr shareInstance] updateSettingInfo:item];
}

- (void)onCloseDataButtonClick:(id)sender
{
    [self dismiss];
}

+ (void)show
{
    WXHongBaoSettingViewController *settingViewController = [[WXHongBaoSettingViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    nav.view.backgroundColor = [UIColor whiteColor];
    [[[UIApplication sharedApplication] currentTopViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
