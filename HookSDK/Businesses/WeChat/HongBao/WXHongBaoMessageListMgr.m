//
//  WXHongBaoMessageListMgr.m
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import "WXHongBaoMessageListMgr.h"

@interface WXHongBaoMessageListMgr ()

@property (nonatomic, strong) NSMutableArray<CMessageWrap *> *autoOpenMessageList;

@end


@implementation WXHongBaoMessageListMgr

+ (instancetype)shareInstance
{
    static id sss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sss = [[[self class] alloc] init];
    });
    
    return sss;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.messageList = [[NSMutableArray alloc] init];
        self.autoOpenMessageList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addHongBaoMessage:(CMessageWrap *)message
{
    [self.messageList addObject:message];
}

- (CMessageWrap *)hongBaoMessageBySendId:(NSString *)sendId
{
    for (CMessageWrap *wrap in self.messageList )
    {
        NSDictionary *nativeUrlDict = [self hongBaoParseNativeURLWithMessage:wrap];
        NSString *messageSendId = [nativeUrlDict stringForKey:@"sendid"];
        if ( [sendId isEqualToString:messageSendId] )
        {
            return wrap;
        }
    }
    
    return nil;
}

- (NSString *)hongBaoNativeURLWithMessage:(CMessageWrap *)wrap
{
    return [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
}

- (NSDictionary *)hongBaoParseNativeURLWithMessage:(CMessageWrap *)wrap
{
    NSString *nativeURL = [self hongBaoNativeURLWithMessage:wrap];
    
    return [self hongBaoParseNativeURL:nativeURL];
}

- (NSDictionary *)hongBaoParseNativeURL:(NSString *)nativeURL
{
    NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
        nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
        return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
    };
    
    NSDictionary *nativeUrlDict = parseNativeUrl(nativeURL);
    
    return nativeUrlDict;
}

- (NSString *)sendIdFromNativeURL:(NSString *)nativeURL
{
    NSDictionary *dic = [self hongBaoParseNativeURL:nativeURL];
    
    return [dic stringForKey:@"sendid"];
}

- (NSString *)sendIdFromMessage:(CMessageWrap *)wrap
{
    if ( wrap == nil )
    {
        return nil;
    }
    
    NSString *nativeURL = [self hongBaoNativeURLWithMessage:wrap];
    
    return [self sendIdFromNativeURL:nativeURL];
}

- (BOOL)isHongBaoMessage:(CMessageWrap *)wrap
{
    BOOL vaild = wrap && wrap.m_uiMessageType == 49;
    vaild = vaild && [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
    
    return  vaild;
}

- (WeChatRedEnvelopParam *)hongBaoEnvelopParamWithSendId:(NSString *)sendId
{
    CMessageWrap *wrap = [self hongBaoMessageBySendId:sendId];
    
    return [self hongBaoEnvelopParamWithMessage:wrap];
}

- (WeChatRedEnvelopParam *)hongBaoEnvelopParamWithMessage:(CMessageWrap *)wrap
{
    if ( wrap == nil )
    {
        return nil;
    }
    
    CContactMgr *contactManager = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
    CContact *selfContact = [contactManager getSelfContact];
    NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
    NSDictionary *nativeUrlDict = [[WXHongBaoMessageListMgr shareInstance] hongBaoParseNativeURL:nativeUrl];
    
    BOOL (^isSender)() = ^BOOL() {
        return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
    };
    
    BOOL isGroupSender = isSender && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
    
    WeChatRedEnvelopParam * (^makeupParams)(NSDictionary *nativeUrlDict) = ^WeChatRedEnvelopParam *(NSDictionary *nativeUrlDict) {
        WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
        mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
        mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
        mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
        mgrParams.nickName = [selfContact getContactDisplayName];
        mgrParams.headImg = [selfContact m_nsHeadImgUrl];
        mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
        mgrParams.sessionUserName = isGroupSender ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
        mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];
        mgrParams.isGroupSender = isGroupSender;
        
        return mgrParams;
        
    };
    
    return makeupParams( nativeUrlDict );
}

- (NSString *)hongBaoTitleWithMessage:(CMessageWrap *)wrap
{
    if ( wrap == nil || wrap.m_nsContent == nil )
    {
        return nil;
    }
    
    NSString *content = wrap.m_nsContent;
    NSString *startString = nil;
    NSString *endString = nil;
    NSRange startRange ;
    NSRange endRange;
    NSRange range ;
    NSString *title = nil;
    
    startString = @"<sendertitle>";
    endString = @"</sendertitle>";
    startRange = [content rangeOfString:startString];
    endRange = [content rangeOfString:endString];
    
    if ( startRange.location == NSNotFound || endRange.location == NSNotFound )
    {
        return nil;
    }
    
    range.location = startRange.location + startRange.length;
    range.length = endRange.location - startRange.location - startRange.length;
    title = [content substringWithRange:range];
    
    startString = @"![CDATA[";
    endString = @"]]>";
    startRange = [title rangeOfString:startString];
    endRange = [title rangeOfString:endString];
    
    if ( startRange.location == NSNotFound || endRange.location == NSNotFound )
    {
        return nil;
    }
    
    range.location = startRange.location + startRange.length;
    range.length = endRange.location - startRange.location - startRange.length;
    
    NSString *fixTitle = [title substringWithRange:range];

    return fixTitle;
}

- (NSString *)groupNameFromMessage:(CMessageWrap *)wrap
{
    CContactMgr *contactManager = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
    CContact* contactTemp = [contactManager getContactByName:[wrap GetChatName]];
    if ( nil != contactTemp )
    {
        NSString* strNickName = [contactTemp m_nsNickName];
        return strNickName;
    }
    
    return nil;
}

- (void)addAutoOpenHongBaoMesage:(CMessageWrap *)wrap
{
    [self.autoOpenMessageList addObject:wrap];
}

- (BOOL)isAutoOpenHongBaoMesage:(CMessageWrap *)wrap
{
    for ( CMessageWrap * autoWrap in self.autoOpenMessageList )
    {
        if ( autoWrap == wrap )
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)addTimingId:(NSString *)timingId name:(NSString *)name
{
    if ( self.timingIdDictionary == nil )
    {
        self.timingIdDictionary = [NSMutableDictionary dictionary];
    }
    
    [self.timingIdDictionary setObject:timingId forKey:name];
}

- (NSString *)timingIdOfName:(NSString *)name
{
    return [self.timingIdDictionary objectForKey:name];
}

- (BOOL)isSendByMe:(CMessageWrap *)wrap
{
    CContactMgr *contactManager = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
    CContact *selfContact = [contactManager getSelfContact];
    
    return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
}

@end
