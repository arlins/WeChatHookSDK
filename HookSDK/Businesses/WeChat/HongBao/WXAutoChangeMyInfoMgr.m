//
//  WXAutoChangeMyInfoMgr.m
//  HookSDK
//
//  Created by arlin on 17/4/4.
//
//

#import "WXAutoChangeMyInfoMgr.h"
#import "WeChatRedEnvelop.h"
#import <objc/runtime.h>
#import "UIApplication+TopViewController.h"
#import "NSObject+HKInstanceVariable.h"
#import "WXHongBaoSettingMgr.h"

typedef void(^EditAction)(UIView *view);

@interface WXAutoChangeMyInfoMgr ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation WXAutoChangeMyInfoMgr

+ (instancetype)shareInstance
{
    static id ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXHongBaoSettingUpdate) name:KWXHongBaoSettingUpdate object:nil];
    }
    
    return self;
}

- (void)autoChangeMyInfo
{
    SettingMyProfileViewController *vc = [[[objc_getClass("SettingMyProfileViewController") class] alloc] init];

    [vc initDeepLinkConfig];
    
//    UINavigationController *vvc = [[UINavigationController alloc] initWithRootViewController:vc];
//    
//    [[[UIApplication sharedApplication] currentTopViewController] presentViewController:vc animated:NO completion:nil];
    
    [self changeNickName:vc];
    [self changeHeadImage:vc];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [vc showModifyNickName];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            [self changeNickName:vc];
//            [self changeHeadImage:vc];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [vvc dismissViewControllerAnimated:YES completion:nil];
//            });
//        });
//    });
}

- (void)changeHeadImage:(SettingMyProfileViewController *)vc
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(concurrentQueue, ^(){
        NSURL *url = [NSURL URLWithString:[self randomHeadImageURL]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            MMHeadImageMgr *logicMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMHeadImageMgr")];
            [logicMgr uploadHDHeadImg:image];
        });
    });
}

- (void)changeNickName:(SettingMyProfileViewController *)vc
{
//    NameEditorViewController * nameVC = (NameEditorViewController *)[[UIApplication sharedApplication] currentTopViewController];
//    
//    NSLog(@"%@ %@", nameVC, [nameVC class] );
//    
//    if ( nameVC && [nameVC isKindOfClass:NSClassFromString(@"NameEditorViewController")] )
//    {
//        MMTableViewInfo *tableViewInfo = [nameVC instanceObjectVariableOf:@"m_tableViewInfo"];
//        MMTableView *tableView = [tableViewInfo getTableView];
//        
//        [self findSubView:tableView action:^(UIView *view) {
//            if ( [view isKindOfClass:[UITextField class]] )
//                  {
//                      UITextField *textField = (UITextField *)view;
//                      
//                      UITextPosition *endDocument = textField.endOfDocument;
//                      UITextRange *range = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:endDocument];
//                    
//                      [textField replaceRange:range withText:[self randomNickName]];
//            }
//        }];
//        
//        
//        NSLog(@"%@", nameVC.navigationItem.rightBarButtonItems );
//        for ( UIBarButtonItem *item in nameVC.navigationItem.rightBarButtonItems )
//        {
//            MMBarButtonItem *iit = (MMBarButtonItem *)item;
//            if ( [iit isKindOfClass:NSClassFromString(@"MMBarButtonItem")] )
//            {
//                NSLog(@"%@", [iit.m_btn titleForState:UIControlStateNormal]);
//                [iit setEnabled:YES];
//                [iit.m_btn setEnabled:YES];
//                [iit.m_btn sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//        }
//    }

    NSString *nickName = [self randomNickName];
    [vc onModifyNickName:nickName vc:nil];
}

- (void)findSubView:(UIView*)view action:(EditAction)action
{
    for (UIView* subView in view.subviews)
    {
        action( subView );
        [self findSubView:subView action:action];
    }
}

- (NSString *)randomNickName
{
    NSArray *list = [self defaultNickNameList];
    static int i = -1;
    i ++;
    if ( i > list.count - 1 )
    {
        i = -1;
    }
    
    return [list objectAtIndex:i];
}

- (NSString *)randomHeadImageURL
{
    NSArray *list = [self defalutHeadImageURLList];
    
    static int i = -1;
    i ++;
    if ( i > list.count - 1 )
    {
        i = -1;
    }
    
    return [list objectAtIndex:i];
}

- (NSArray *)defaultNickNameList
{
    return @[@"悉数沉淀",
             @"暖寄归人",
             @"瞎闹腾",
             @"厌世症",
             @"人心可畏",
             @"你真逗比",
             @"前凸后翘",
             @"可喜可乐 ",
             @"以心换心 ",
             @"渣中王",
             @"一干为尽 ",
             @"你的愚忠 ",
             @"就是任性 ",
             @"缺氧患人",
             @"住进时光里 ",
             @"难免心酸° ",
             @"只为你生！ ",
             @"前后都是你 ",
             @"☀陌离女王 ",
             @"缺我也没差 ",
             @"十年温如初 ",
             @"闹够了就滚 ",
             @"单身女王 ",
             @"我心透心凉 ",
             @"有钱就是任性 ",
             @"爱情就是难题 ",
             @"国名小逗比！ ",
             @"我脑残我乐意 ",
             @"你会腻我何必 ",
             @"钻石女王心",
             @"枪蹦狗友",
             @"美美的校霸花 ",
             @"装逼不适合你 ",
             @"隔壁王学长",
             @"带我装逼带我飞",
             @"没刘海照样拽 ",
             @"深爱是场谋杀！ ",
             @"我一贱你就笑 ",
             @"-深情不及久伴 ",
             @"怎样自在怎样活 ",
             @"为梦喧闹只为你 ",
             @"没资本就别装纯 ",
             @"姐的拽、你不懂 ",
             @"这辈子赖定你了 ",
             @"灵魂深处有个他 ",
             @"众人皆醉我独醒 ",
             @"深爱是场谋杀。 ",
             @"妲己再美终是妃 ",
             @"不再眠心悲凉",
             @"女人无情便是王 ",
             @"给我五厘米的高度 ",
             @"喜欢你是我有病 ",
             @"往事讽刺笑到肚疼 ",
             @"酌酒一杯赐你饮下 ",
             @"爱我毁她你好吊 ",
             @"脾气酸独与你温柔 ",
             @"听说你是个茬子; ",
             @"我想请你次辣条",
             @"哇！原来你也是人 ",
             @"别拿装逼当典范！ ",
             @"旧时光她是个美人 ",
             @"一身傲骨怎能服输 ",
             @"你与氧气共存亡 ",
             @"当你的眼睛眯着笑 ",
             @"时光凉透初时模样",
             @"劳资丿平底鞋走天下 ",
             @"一辈子都当女超人",
             @"赐毒酒一杯给那贱人 ",
             @"香烟520",
             @"默默的承受",
             @"骄傲到自负",
             @"默默的离开",
             @"默默的付出",
             @"释怀",
             @"笑叹。红尘", 
             @"傻蛋也有爱情"];
}

- (NSArray *)defalutHeadImageURLList
{
    return @[@"http://img2.100bt.com/upload/ttq/20131103/1383470553132_middle.jpg",
             @"http://img.52touxiang.net/uploads/allimg/141226/220539D93-14.jpg",
             @"http://diy.qqjay.com/u2/2012/0913/55a80cdb4fca56c77c12a38c079bf6ab.jpg",
             @"http://img5.imgtn.bdimg.com/it/u=2033397853,2413356146&fm=23&gp=0.jpg",
             @"http://www.qqbody.com/uploads/allimg/201304/12-215001_380.jpg",
             @"http://tupian.qqjay.com/tou2/2017/0129/9dac81c8ff947fe0291cf467a2fe9b63.jpg",
             @"http://www.th7.cn/d/file/p/2014/02/28/28c29afb5bf2c3b58682b8ffe06615aa.jpg",
             @"http://img.woyaogexing.com/2015/09/20/74dae5a9035fa4d5%21200x200.jpg",
             @"http://tupian.qqjay.com/tou2/2017/0129/81176d8f15ffcb6b9b51ad5443ad1068.jpg",
             @"http://v1.qzone.cc/avatar/201508/04/11/07/55c02c89e7757728.jpg%21200x200.jpg",
             @"http://v1.qzone.cc/avatar/201311/23/11/03/52901b1565ca9648.jpg%21200x200.jpg",
             @"http://img4.duitang.com/uploads/item/201601/04/20160104144829_G5K4c.jpeg",
             @"http://img.woyaogexing.com/2016/11/07/f139f0ca6662ff33%21200x200.jpg",
             @"http://tx.haiqq.com/uploads/allimg/150330/234I5H31-2.jpg",
             @"http://img2.hao661.com/uploads/allimg/c140912/141051V94b5F-J6318-lit.jpg",
             @"http://v1.qzone.cc/avatar/201303/19/20/28/514859e4e74e9877.jpg%21200x200.jpg",
             @"http://diy.qqjay.com/u2/2014/1208/ac9aa749faa68eecd84ed14b2da0f9e3.jpg",
             @"http://img4.imgtn.bdimg.com/it/u=431898331,624921566&fm=214&gp=0.jpg",
             @"http://tupian.enterdesk.com/2014/xll/11/15/1/touxiang15.jpg",
             @"http://www.onegreen.net/QQ/UploadFiles/201307/2013071405563599.jpg",
             @"http://img0.imgtn.bdimg.com/it/u=3706498776,4282500579&fm=214&gp=0.jpg",
             @"http://up.qqjia.com/z/01/tu3958_17.jpg",
             @"http://www.qqbody.com/uploads/allimg/201401/09-045302_796.jpg",
             @"http://www.2cto.com/uploadfile/2012/1207/20121207081844809.jpg",
             @"http://www.feizl.com/upload2007/2014_03/1403271433446320.jpg",
             @"http://up.qqjia.com/z/21/tu24048_3.jpg",
             @"http://img0.imgtn.bdimg.com/it/u=3710595601,2183417659&fm=214&gp=0.jpg",
             @"http://www.itouxiang.net/uploads/allimg/20151218/08182217064987.jpg",
             @"http://img1.skqkw.cn:888/2014/11/11/12/4g1gfpkipoq-7965.jpg",
             @"http://tupian.qqjay.com/tou2/2017/0129/e85af01dd8f58d2d97912d8ee043cc91.jpg",
             @"http://www.soideas.cn/uploads/allimg/110522/0H4213947-7.jpg",
             @"http://tupian.qqjay.com/tou2/2017/0129/1b81f84500ce21d312396e894cb90ae9.jpg",
             @"http://d.hiphotos.baidu.com/zhidao/pic/item/30adcbef76094b3647f4a66ca1cc7cd98c109dc9.jpg",
             @"http://img5.duitang.com/uploads/item/201410/19/20141019080247_mhzZC.thumb.224_0.jpeg",
             @"http://tupian.qqjay.com/tou2/2017/0129/6b204385dce49ed399e78f4c34d6860c.jpg",
             @"http://img.520zhxx.com:8033/touxiang/2014/06/01/20/201406012024103050.jpg",
             @"http://img.52touxiang.net/uploads/allimg/141226/2205395231-10.jpg",
             @"http://g.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=67a49f53b019ebc4c02d7e9db716e3ca/fc1f4134970a304e3b8a00ccd2c8a786c9175c5f.jpg",
             @"http://img4.imgtn.bdimg.com/it/u=4223911797,1105930258&fm=214&gp=0.jpg",
             @"http://www.wzfzl.cn/uploads/allimg/170119/150202L32-5.jpg"];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

- (void)start
{
    [self stop];
    
    if ( [[WXHongBaoSettingMgr shareInstance] autoChangeInfo] )
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onTimerTimeout:) userInfo:nil repeats:YES];
    }
}

- (void)stop
{
    if ( self.timer )
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onTimerTimeout:(id)sender
{
    [self autoChangeMyInfo];
}

- (void)onWXHongBaoSettingUpdate
{
    [self start];
}

@end
