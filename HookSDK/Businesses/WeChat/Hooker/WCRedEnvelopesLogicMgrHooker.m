//
//  WCRedEnvelopesLogicMgrHooker.m
//  HookSDK
//
//  Created by arlin on 17/3/11.
//
//

#import "WCRedEnvelopesLogicMgrHooker.h"
#import "WeChatRedEnvelop.h"
#import "NSObject+HKMethodSwizzed.h"
#import "WeChatHookSDK.h"
#import "NSObject+HSClassInfo.h"
#import "NSDictionary+HKPrint.h"
#import "WeChatRedEnvelopParam.h"
#import <objc/runtime.h>
#import "NSDictionary+HKPrint.h"
#import "WXHongBaoMessageListMgr.h"
#import "WXHongBaoIPCCmdMgr.h"
#import "WXHongBaoOpeartionMgr.h"
#import "WXHongBaoSettingMgr.h"
#import "WXHongBaoQueryTaskMgr.h"
#import "WXHongBaoReporter.h"
#import "HKAppAuthorizationMgr.h"
#import "WXHongBaoRuleManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation WCRedEnvelopesLogicMgrHooker

- (void)wxhk_OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2
{
    [self wxhk_OnWCToHongbaoCommonResponse:arg1 Request:arg2];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_OnWCToHongbaoCommonResponse");
    
    if ( ![arg1 isKindOfClass:NSClassFromString(@"HongBaoRes")] )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"arg1 is not HongBaoRes");
        return;
    }
    
    if ( ![arg2 isKindOfClass:NSClassFromString(@"HongBaoReq")] )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"arg1 is not HongBaoReq");
        return;
    }

    NSString *log = [NSString stringWithFormat:@"cgiCmdid = %d", arg1.cgiCmdid];
    HKTagNSLog( KWeChatHookSDKLog, log );
    
    //红包状态查询
    if ( arg1.cgiCmdid == 3 )
    {
        if ( arg1.errorType != 0 )
        {
            return;
        }
        
        NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        
        [WCRedEnvelopesLogicMgrHooker handleReceiverQueryHongBaoRespone:responseDict requestString:requestString];
    }
    
    //领取结果
    if ( arg1.cgiCmdid == 4 )
    {
        if ( arg1.errorType != 0 )
        {
            return;
        }
        
        NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
        
        [WCRedEnvelopesLogicMgrHooker handleOpenHongBaoRespone:responseDict];
    }
    
    //查询领取详情返回结果
    if ( arg1.cgiCmdid == 5 )
    {
        if ( arg1.errorType != 0 )
        {
            return;
        }
        
        NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
        [WCRedEnvelopesLogicMgrHooker handleHongBaoQueryRespone:responseDict];
    }
}

+ (void)handleReceiverQueryHongBaoRespone:(NSDictionary *)responseDict requestString:(NSString *)requestString
{
    /*
     [__NSCFString]watermark : [__NSCFConstantString]
     [__NSCFString]retmsg : [__NSCFString]ok
     [__NSCFString]retcode : [__NSCFNumber]0
     [__NSCFString]wishing : [__NSCFString]30/2
     [__NSCFString]hbStatus : [__NSCFNumber]2
     [__NSCFString]isSender : [__NSCFNumber]1
     [__NSCFString]sendId : [__NSCFString]1000039501201703156025108776003
     [__NSCFString]timingIdentifier : [__NSCFString]F612F798747A74D04B4B20E069EA2294
     [__NSCFString]statusMess : [__NSCFString]发了一个红包，金额随机
     [__NSCFString]sendUserName : [__NSCFString]wxid_gr8sj9hhytkj12
     [__NSCFString]hbType : [__NSCFNumber]1
     [__NSCFString]receiveStatus : [__NSCFNumber]0
     */
    
    NSDictionary *requestDictionary = [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:requestString separator:@"&"];
    NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
    NSDictionary *nativeUrlDict = [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
    
    NSString *sendId = [nativeUrlDict stringForKey:@"sendid"];
    NSString *timingId = responseDict[@"timingIdentifier"];
    
    [[WXHongBaoMessageListMgr shareInstance] addTimingId:timingId name:sendId];
    
    CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:sendId];
    
    if ( wrap == nil )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"列表无此红包1");
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"列表无此红包"];
        }
        
        return;
    }
    
    WeChatRedEnvelopParam *mgrParams = [[WXHongBaoMessageListMgr shareInstance] hongBaoEnvelopParamWithMessage:wrap];
    
    if ( mgrParams == nil )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"列表无此红包2");
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"列表无此红包"];
        }
    }
    
    BOOL shouldReceiveRedEnvelop = YES;
    
    if ([[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        //主号手动打开的只要满足条件也要通知小号
        if ( ![[WXHongBaoOpeartionMgr shareInstance] testHongBaoMessageCanAutoOpen:wrap log:YES] )
        {
            shouldReceiveRedEnvelop = NO;
        }
        
        if ( ![[WXHongBaoMessageListMgr shareInstance] isAutoOpenHongBaoMesage:wrap] )
        {
            HKTagNSLog(KWeChatHookSDKLog, @"不是自动抢包");
            
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"不是自动抢包"];
            }
            
            shouldReceiveRedEnvelop = NO;
        }
    }
    
    if ( ![[WXHongBaoSettingMgr shareInstance] isMaster] )
    {
        //结果来自小号查询TimingId，不应该处理
        BOOL isRunningQueryStateTask = [[WXHongBaoQueryTaskMgr shareInstance] isRunningQueryStateTaskOf:nativeUrl];
        
        if ( isRunningQueryStateTask )
        {
            HKTagNSLog(KWeChatHookSDKLog, @"自动查询状态结果");
            if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
            {
                [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"自动查询状态结果"];
            }
            
            shouldReceiveRedEnvelop = NO;
        }
    }
    
    // 自己已经抢过
    if ([responseDict[@"receiveStatus"] integerValue] == 2)
    {
        HKTagNSLog(KWeChatHookSDKLog, @"已经抢过红包");
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"已经抢过红包"];
        shouldReceiveRedEnvelop = NO;
    }
    
    // 红包被抢完
    if ([responseDict[@"hbStatus"] integerValue] == 4)
    {
        HKTagNSLog(KWeChatHookSDKLog, @"红包被抢完了");
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"红包被抢完了"];
        shouldReceiveRedEnvelop = NO;
    }
    
    // 没有这个字段会被判定为使用外挂
    if (!responseDict[@"timingIdentifier"])
    {
        HKTagNSLog(KWeChatHookSDKLog, @"判定使用外挂");
        [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"判定使用外挂"];
        shouldReceiveRedEnvelop = NO;
    }
    
    NSString *log = [NSString stringWithFormat:@"responseDict = %@", [responseDict outputAllKeysAndValues]];
    HKTagNSLog(KWeChatHookSDKLog, log);
    
    [[WXHongBaoQueryTaskMgr shareInstance] stopQueryHongBaoStateTask:nativeUrl];
    
    if ( shouldReceiveRedEnvelop )
    {
        mgrParams.timingIdentifier = timingId;
        
        //抢红包
        HKTagNSLog(KWeChatHookSDKLog, @"-- 开始抢红包 1 ");
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"开始抢红包"];
        }
        
        [[WXHongBaoOpeartionMgr shareInstance] wxOpenRedEnvelopesRequest:[mgrParams toParams]];
    }
    else
    {
        HKTagNSLog(KWeChatHookSDKLog, @"不抢红包");
    }
}

+ (void)handleOpenHongBaoRespone:(NSDictionary *)responseDict
{
    /*
     0.15
     
     [__NSCFString]statusMess : [__NSCFConstantString]
     [__NSCFString]record : [__NSArrayI](
     {
     answer = "";
     gameTips = "\U624b\U6c14\U6700\U4f73";
     receiveAmount = 15;
     receiveId = 1000039501001703156023966811120;
     receiveOpenId = 1000039501001703156023966811120;
     receiveTime = 1489559919;
     state = 1;
     userName = "wxid_gr8sj9hhytkj12";
	    },
     {
     answer = "";
     receiveAmount = 1;
     receiveId = 1000039501000703156023966811120;
     receiveOpenId = 1000039501000703156023966811120;
     receiveTime = 1489559900;
     state = 1;
     userName = arlin9;
	    }
     )
     [__NSCFString]operationHeader : [__NSArrayI](
     )
     [__NSCFString]isSender : [__NSCFNumber]1
     [__NSCFString]retmsg : [__NSCFString]ok
     [__NSCFString]totalAmount : [__NSCFNumber]16
     [__NSCFString]changeWording : [__NSCFString]已存入零钱，可直接提现
     [__NSCFString]real_name_info : [__NSDictionaryI]{
	    "guide_flag" = 1;
	    "guide_wording" = "\U6839\U636e\U56fd\U5bb6\U6cd5\U89c4\U5bf9\U652f\U4ed8\U670d\U52a1\U5b9e\U540d\U5236\U7684\U8981\U6c42\Uff0c\U4f60\U9700\U8981\U5c3d\U5feb\U5b8c\U6210\U5b9e\U540d\U8ba4\U8bc1\Uff0c\U4ee5\U786e\U4fdd\U6b63\U5e38\U4f7f\U7528\U5fae\U4fe1\U652f\U4ed8\U529f\U80fd";
	    "left_button_wording" = "\U4e0b\U6b21\U518d\U8bf4";
	    "right_button_wording" = "\U7acb\U5373\U8ba4\U8bc1";
     }
     [__NSCFString]recNum : [__NSCFNumber]2
     [__NSCFString]recAmount : [__NSCFNumber]16
     [__NSCFString]hbType : [__NSCFNumber]1
     [__NSCFString]isContinue : [__NSCFNumber]0
     [__NSCFString]receiveId : [__NSCFString]1000039501001703156023966811120
     [__NSCFString]hasWriteAnswer : [__NSCFNumber]0
     [__NSCFString]receiveStatus : [__NSCFNumber]2
     [__NSCFString]amount : [__NSCFNumber]15
     [__NSCFString]canShare : [__NSCFNumber]0
     [__NSCFString]totalNum : [__NSCFNumber]2
     [__NSCFString]sendUserName : [__NSCFString]wxid_gr8sj9hhytkj12
     [__NSCFString]sendId : [__NSCFString]1000039501201703156023966811120
     [__NSCFString]watermark : [__NSCFConstantString]
     [__NSCFString]headTitle : [__NSCFString]2个红包共0.16元，26秒被抢光
     [__NSCFString]jumpChange : [__NSCFNumber]1
     [__NSCFString]hbStatus : [__NSCFNumber]4
     [__NSCFString]sessionUserName : [__NSCFString]7905509062@chatroom
     [__NSCFString]retcode : [__NSCFNumber]0
     [__NSCFString]wishing : [__NSCFString]恭喜发财，大吉大利
     }
     */
    
    
    NSUInteger amount = ((NSNumber *)responseDict[@"amount"]).integerValue;
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    NSString *sendId = responseDict[@"sendId"];
    NSString *wishing = responseDict[@"wishing"];
    NSString *log = [NSString stringWithFormat:@"handleOpenHongBaoRespone:%@", [responseDict outputAllKeysAndValues]];
    HKTagNSLog(KWeChatHookSDKLog, log);
    
    NSString *cmd = [NSString stringWithFormat:@"领取红包:%@", wishing];
    HKTagNSLog(KWeChatHookSDKLog, cmd);
    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:cmd];
    
    cmd = [NSString stringWithFormat:@"领取金额:%.2f", amount*0.01];
    HKTagNSLog(KWeChatHookSDKLog, cmd);
    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:cmd];
    
    //领取金额上报
    CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:sendId];
    NSString *groupName = [[WXHongBaoMessageListMgr shareInstance] groupNameFromMessage:wrap];
    
    if ( [[WXHongBaoSettingMgr shareInstance] isGroupNameVaild:groupName] )
    {
        NSString *appKey = [[HKAppAuthorizationMgr shareInstance] appKey];
        NSString *nickName = [[WXHongBaoOpeartionMgr shareInstance] getMyNickName];
        NSString *accountStyle = [[WXHongBaoSettingMgr shareInstance] isMaster]?@"one":@"two";
        NSString *log = [[WXHongBaoReporter shareInstance] reportAmountInfoToServer:amount
                                                             appKey:appKey
                                                        accountName:nickName
                                                       accountStyle:accountStyle];
        
        log = [NSString stringWithFormat:@"领取数据上报:%@", log];
        HKTagNSLog(KWeChatHookSDKLog, log);
        
        BOOL openTip = [[WXHongBaoRuleManager shareInstance] testOpenResultTip:totalNum recvCount:recNum totalAmount:totalAmount recvAmount:recAmount recvList:nil amountByMe:amount title:wishing log:nil];
        if ( openTip )
        {
            AudioServicesPlaySystemSound(1073);
        }
    }
}

+ (void)handleHongBaoQueryRespone:(NSDictionary *)responseDict
{
    /*
     [__NSCFString]record : [__NSArrayI](
     {
     answer = "";
     receiveAmount = 12;
     receiveId = 1000039501000703146060087061064;
     receiveOpenId = 1000039501000703146060087061064;
     receiveTime = 1489508396;
     state = 1;
     userName = arlin9;
	    }
     )
     [__NSCFString]isSender : [__NSCFNumber]1
     [__NSCFString]retmsg : [__NSCFString]ok
     [__NSCFString]totalAmount : [__NSCFNumber]31
     [__NSCFString]changeWording : [__NSCFString]已存入零钱，可用于发红包
     [__NSCFString]hbKind : [__NSCFNumber]1
     [__NSCFString]recNum : [__NSCFNumber]1
     [__NSCFString]receiveId : [__NSCFString]1000039501000703146060087061064
     [__NSCFString]hbType : [__NSCFNumber]1
     [__NSCFString]isContinue : [__NSCFNumber]0
     [__NSCFString]recAmount : [__NSCFNumber]12
     [__NSCFString]hasWriteAnswer : [__NSCFNumber]0
     [__NSCFString]operationTail : [__NSDictionaryI]{
     content = "";
     enable = 1;
     iconUrl = "";
     name = "\U672a\U9886\U53d6\U7684\U7ea2\U5305\Uff0c\U5c06\U4e8e24\U5c0f\U65f6\U540e\U53d1\U8d77\U9000\U6b3e";
     ossKey = 4294967295;
     type = Text;
     }
     [__NSCFString]receiveStatus : [__NSCFNumber]2
     [__NSCFString]atomicFunc : [__NSDictionaryI]{
     enable = 0;
     }
     [__NSCFString]amount : [__NSCFNumber]12
     [__NSCFString]canShare : [__NSCFNumber]0
     [__NSCFString]totalNum : [__NSCFNumber]3
     [__NSCFString]sendUserName : [__NSCFString]arlin9
     [__NSCFString]sendId : [__NSCFString]1000039501201703146060087061064
     [__NSCFString]headTitle : [__NSCFString]已领取1/3个，共0.12/0.31元
     [__NSCFString]jumpChange : [__NSCFNumber]1
     [__NSCFString]hbStatus : [__NSCFNumber]3
     [__NSCFString]retcode : [__NSCFNumber]0
     [__NSCFString]wishing : [__NSCFString]我们自己
     */
    
    NSString *sendId = responseDict[@"sendId"];
    NSString *title = responseDict[@"wishing"];
    
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    
    //总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    
    //已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    
    //操作结果
    NSInteger retcode = ((NSNumber *)responseDict[@"retcode"]).integerValue;
    
    if ( retcode != 0 )
    {
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"查询领取失败"];
        }
        
        return;
    }
    
    BOOL isMaster = [[WXHongBaoSettingMgr shareInstance] isMaster];
    
    if ( !isMaster )
    {
        return;
    }
    
    CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:sendId];
    
    if ( wrap == nil || totalNum == 0 || recNum == 0 )
    {
        return;
    }
    
    if ( ![[WXHongBaoQueryTaskMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }
    
    NSArray *recvList = [[self class] makeupReceiverRecordList:responseDict];
    NSMutableArray *logArray = [NSMutableArray array];
    WXHongBaoRuleMatchResult res = [[WXHongBaoRuleManager shareInstance] testQueryDetail:totalNum
                                                                               recvCount:recNum
                                                                             totalAmount:totalAmount
                                                                              recvAmount:recAmount
                                                                                recvList:recvList
                                                                                   title:title
                                                                                     log:logArray];
    
    if ( res != WXHongBaoRuleMatchResultIgnore )
    {
        //停止查询任务
        [[WXHongBaoQueryTaskMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
    }
    
    switch ( res )
    {
        case WXHongBaoRuleMatchResultValid:
            {
                for ( NSString *singleLog in logArray )
                {
                    //输出日志
                    HKTagNSLog(KWeChatHookSDKLog, singleLog);
                    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:singleLog];
                }
                
                //通知小号领取
                BOOL canNotice = [[WXHongBaoSettingMgr shareInstance] canNotice];
                if ( canNotice )
                {
                    NSString *nativeURL = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    HKTagNSLog(KWeChatHookSDKLog, @"通知小号领取");
                    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"通知小号领取"];
                    
                    [[WXHongBaoIPCCmdMgr shareInstance] sendAutoOpenHongBao:nativeURL];
                }
                else
                {
                    HKTagNSLog(KWeChatHookSDKLog, @"不通知小号");
                    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"不通知小号"];
                }
            }
            break;
        case WXHongBaoRuleMatchResultInvaild:
            {
                for ( NSString *singleLog in logArray )
                {
                    //输出错误日志
                    HKTagNSLog(KWeChatHookSDKLog, singleLog);
                    [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:singleLog];
                }
            }
            break;
        case WXHongBaoRuleMatchResultIgnore:
            break;
        default:
            break;
    }
}

+ (NSArray *)makeupReceiverRecordList:(NSDictionary *)responeDic
{
    NSMutableArray *arr = [NSMutableArray array];
    NSArray *list = responeDic[@"record"];
    for ( NSDictionary *info in list )
    {
        if ( ![info isKindOfClass:[NSDictionary class]] )
        {
            continue;
        }
        
        WXHongBaoRecvRecordInfo *recordItem = [[WXHongBaoRecvRecordInfo alloc] init];
        recordItem.receiveAmount = ((NSNumber *)(info[@"receiveAmount"])).unsignedIntegerValue;
        recordItem.userName = info[@"userName"];
        
        [arr addObject:recordItem];
    }
    
    return arr;
}

- (void)wxhk_OnWCToHongbaoCommonErrorResponse:(id)arg1 Request:(HongBaoReq *)arg2
{
    //[self wxhk_OnWCToHongbaoCommonErrorResponse:arg1 Request:arg2];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_OnWCToHongbaoCommonErrorResponse");
    
    NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
    NSDictionary *requestDictionary = [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:requestString separator:@"&"];
    NSString *sendId = [requestDictionary stringForKey:@"sendId"];
    CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:sendId];
    
    if ( [[WXHongBaoQueryTaskMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        HKTagNSLog(KWeChatHookSDKLog, @"停止错误查询领取详情");
        if ( [[WXHongBaoSettingMgr shareInstance] enableFullLog] )
        {
            [[WXHongBaoIPCCmdMgr shareInstance] sendLogCmdWithFromApp:@"停止错误查询领取详情"];
        }
        
        [[WXHongBaoQueryTaskMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
    }
}

- (void)wxhk_OnWCToHongbaoCommonSystemErrorResponse:(id)arg1 Request:(id)arg2
{
    //[self wxhk_OnWCToHongbaoCommonSystemErrorResponse:arg1 Request:arg2];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_OnWCToHongbaoCommonSystemErrorResponse");
    HKTagNSLog(KWeChatHookSDKLog, NSStringFromClass([arg1 class]));
    
    //[NSObject printInstance:arg1];
    //[NSObject printInstance:arg2];
}

//////////////

- (void)wxhk_QueryUserSendOrReceiveRedEnveloperListRequest:(NSDictionary *)arg1
{
    [self wxhk_QueryUserSendOrReceiveRedEnveloperListRequest:arg1];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_QueryUserSendOrReceiveRedEnveloperListRequest");
    [NSObject printInstance:arg1];
}

- (void)wxhk_QueryRedEnvelopesDetailRequest:(NSDictionary *)arg1
{
    [self wxhk_QueryRedEnvelopesDetailRequest:arg1];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_QueryRedEnvelopesDetailRequest");
    
    HKTagNSLog(KWeChatHookSDKLog, [arg1 outputAllKeysAndValues]);
}

- (void)wxhk_OpenRedEnvelopesRequest:(NSDictionary *)arg1
{
    [self wxhk_OpenRedEnvelopesRequest:arg1];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_OpenRedEnvelopesRequest");
    NSString *log = [NSString stringWithFormat:@"%@", [arg1 outputAllKeysAndValues]];
    HKTagNSLog(KWeChatHookSDKLog, log);
    
     CMessageWrap *wrap = [[WXHongBaoMessageListMgr shareInstance] hongBaoMessageBySendId:[arg1 stringForKey:@"sendId"]];
    [[WXHongBaoOpeartionMgr shareInstance] startQueryHongBaoDetailTask:wrap];
}

- (void)wxhk_ReceiverQueryRedEnvelopesRequest:(NSDictionary *)arg1
{
    [self wxhk_ReceiverQueryRedEnvelopesRequest:arg1];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_ReceiverQueryRedEnvelopesRequest");
    NSString *log = [NSString stringWithFormat:@"%@", [arg1 outputAllKeysAndValues]];
    HKTagNSLog(KWeChatHookSDKLog, log);
}

- (void)wxhk_QueryRedEnvelopesUserInfo:(NSDictionary *)arg1
{
    [self wxhk_QueryRedEnvelopesUserInfo:arg1];
    
    HKTagNSLog(KWeChatHookSDKLog, @"wxhk_QueryRedEnvelopesUserInfo");
    NSString *log = [NSString stringWithFormat:@"%@", [arg1 outputAllKeysAndValues]];
    HKTagNSLog(KWeChatHookSDKLog, log);
}

+ (void)hook
{
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_OnWCToHongbaoCommonResponse:Request:) originalSelector:@selector(OnWCToHongbaoCommonResponse:Request:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_OnWCToHongbaoCommonErrorResponse:Request:) originalSelector:@selector(OnWCToHongbaoCommonErrorResponse:Request:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_OnWCToHongbaoCommonSystemErrorResponse:Request:) originalSelector:@selector(OnWCToHongbaoCommonSystemErrorResponse:Request:)];
    
    //
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_QueryUserSendOrReceiveRedEnveloperListRequest:) originalSelector:@selector(QueryUserSendOrReceiveRedEnveloperListRequest:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_OpenRedEnvelopesRequest:) originalSelector:@selector(OpenRedEnvelopesRequest:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_QueryRedEnvelopesUserInfo:) originalSelector:@selector(QueryRedEnvelopesUserInfo:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_QueryRedEnvelopesDetailRequest:) originalSelector:@selector(QueryRedEnvelopesDetailRequest:)];
    
    [NSObject hk_hookInstanceMethod:NSClassFromString(@"WCRedEnvelopesLogicMgrHooker") originalClass:NSClassFromString(@"WCRedEnvelopesLogicMgr") swizzledSelector:@selector(wxhk_ReceiverQueryRedEnvelopesRequest:) originalSelector:@selector(ReceiverQueryRedEnvelopesRequest:)];
}

@end
