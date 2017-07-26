//
//  WXHongBaoLogWindow.m
//  WXHookDemo
//
//  Created by dps on 17/3/13.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "WXHongBaoLogWindow.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "NSString+HKSearch.h"

#define KWXHongBaoLogWindowButtonHeight 30
#define KWXHongBaoLogWindowMarge 10

#define KWXHongBaoLogWindowHeight 280
#define KWXHongBaoLogWindowWidth 220

@interface WXHongBaoLogCell : UITableViewCell

@end

@implementation WXHongBaoLogCell

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setSelected:(BOOL)selected
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.textLabel.frame = self.bounds;
}

@end


@interface WXHongBaoLogWindow () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *textTableView;
@property (nonatomic, strong) UIButton *textCopyButton;
@property (nonatomic, strong) UIButton *textClearButton;
@property (nonatomic, strong) NSMutableArray *messageList;

@end

@implementation WXHongBaoLogWindow

+ (instancetype)shareInstance
{
    static id logWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect logFrame;
        logFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - KWXHongBaoLogWindowWidth ) / 2.0;
        logFrame.origin.y = 60;
        logFrame.size.width = KWXHongBaoLogWindowWidth;
        logFrame.size.height = KWXHongBaoLogWindowHeight;
        
        logWindow = [[WXHongBaoLogWindow alloc] initWithFrame:logFrame];
        [[UIApplication sharedApplication].keyWindow addSubview:logWindow];
    });
    
    return logWindow;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        self.messageList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.layer.cornerRadius = 6.0;
        
//        self.textCopyButton = [[UIButton alloc] initWithFrame:self.bounds];
//        self.textCopyButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
//        self.textCopyButton.titleLabel.textColor = [UIColor whiteColor];
//        self.textCopyButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
//        [self.textCopyButton setTitle:@"复制" forState:UIControlStateNormal];
//        [self.textCopyButton addTarget:self action:@selector(onTextCopyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.textClearButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.textClearButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.textClearButton.titleLabel.textColor = [UIColor whiteColor];
        self.textClearButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.textClearButton setTitle:@"清除" forState:UIControlStateNormal];
        [self.textClearButton addTarget:self action:@selector(onTextClearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.textTableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.textTableView.delegate = self;
        self.textTableView.dataSource = self;
        self.textTableView.backgroundColor = [UIColor clearColor];
        self.textTableView.tableFooterView=[[UIView alloc]init];
        self.textTableView.separatorInset = UIEdgeInsetsZero;
        self.textTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.textTableView registerClass:[WXHongBaoLogCell class] forCellReuseIdentifier:@"WXHongBaoLogCell"];
        
//        [self addSubview:self.textCopyButton];
        [self addSubview:self.textClearButton];
        [self addSubview:self.textTableView];
        
        [self layoutSubviews];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame;
    
    frame.origin.x = KWXHongBaoLogWindowMarge;
    frame.origin.y = KWXHongBaoLogWindowMarge;
    frame.size.height = KWXHongBaoLogWindowButtonHeight;
    frame.size.width = self.frame.size.width - 2*KWXHongBaoLogWindowMarge;
    self.textClearButton.frame = frame;
    
    frame.origin.x = KWXHongBaoLogWindowMarge;
    frame.origin.y = frame.origin.y + frame.size.height + KWXHongBaoLogWindowMarge;
    frame.size.width = self.frame.size.width - 2*KWXHongBaoLogWindowMarge;
    frame.size.height = self.frame.size.height - 3*KWXHongBaoLogWindowMarge - KWXHongBaoLogWindowButtonHeight;
    self.textTableView.frame = frame;
}

- (void)onTextClearButtonClick:(id)s
{
    [UIPasteboard generalPasteboard].strings = nil;
    [self.messageList removeAllObjects];
    [self.textTableView reloadData];
}

- (void)onTextCopyButtonClick:(id)s
{
    NSMutableString *string = [NSMutableString stringWithFormat:@""];
    
    for ( NSString *text in self.messageList )
    {
        if ( ![string isEqualToString:@""] )
        {
            [string appendString:@"\n"];
        }
        
        [string appendString:text];
    }
    
    [UIPasteboard generalPasteboard].string = string;
}

- (void)appendMessage:(NSString *)message
{
    if ( self.messageList.count > 100 )
    {
        [self.messageList removeLastObject];
    }
    
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *fullMessage = [NSString stringWithFormat:@"%@ %@", dateString, message];
    
    [self.messageList addObject:fullMessage];
    [self.textTableView reloadData];
    [self.textTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.textTableView dequeueReusableCellWithIdentifier:@"WXHongBaoLogCell"];
    
    NSString *text = [self.messageList objectAtIndex:indexPath.row];
    BOOL needNoteText = [text hk_containsString:@"[小号]"];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont systemFontOfSize:11.0];
    cell.textLabel.textColor = needNoteText ? [UIColor greenColor] : [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}

@end
