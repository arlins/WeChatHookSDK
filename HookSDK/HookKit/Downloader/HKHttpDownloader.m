#import "HKHttpDownloader.h"
#import "HKHttpDownloadCache.h"

#pragma mark HKHttpDownloadInfoItem

@implementation HKHttpDownloadInfoItem

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    HKHttpDownloadInfoItem *clone = [[HKHttpDownloadInfoItem alloc] init];
    clone.filePath = self.filePath;
    clone.fileSize = self.fileSize;
    clone.tid = self.tid;
    clone.url = self.url;
    
    return clone;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"tid = %@, url = %@, filePath = %@, fileSize = %lld", self.tid, self.url, self.filePath, self.fileSize];
}

@end


#pragma mark HKHttpDownloader()

@interface HKHttpDownloader ()<NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *receiveData;
@property (nonatomic, retain) NSURLConnection *theConnection;
@property (nonatomic, retain) NSURLRequest *request;

- (void)commonInit;

@end


#pragma mark HKHttpDownloader

@implementation HKHttpDownloader

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _downloading = NO;
}

- (void)dealloc
{
    [self stop];
}

- (void)start
{
    [self stop];
    
    self.receiveData = [[NSMutableData alloc] init];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadInfo.url]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                timeoutInterval:60.0];
    self.theConnection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

- (void)stop
{
    if (_theConnection && _downloading)
    {
        [_theConnection cancel];
    }
    
    _downloadInfo.fileSize = 0;
    _downloading = NO;
}

#pragma mark NSURLConnectionDelegate

//接收到http响应
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.downloading = YES;
    self.downloadInfo.fileSize = [response expectedContentLength];
    
    if ([self.delegate respondsToSelector:@selector(hk_HttpDownloadStarted:)])
    {
        [self.delegate hk_HttpDownloadStarted:self];
    }
}

//传输数据
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
    self.downloading = YES;
    
    if ([self.delegate respondsToSelector:@selector(hk_HttpDownloadProcess:process:)])
    {
        if (self.downloadInfo.fileSize > 0)
        {
            float process = ((float)self.receiveData.length)/self.downloadInfo.fileSize;
            [self.delegate hk_HttpDownloadProcess:self process:(float)process];
        }
    }
}

//错误
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(hk_HttpDownloadStoped:success:)])
    {
        [self.delegate hk_HttpDownloadStoped:self success:NO];
    }
}

//成功下载完毕
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( self.downloadInfo.filePath )
    {
        HKHttpDownloadCache *cache = [HKHttpDownloadCache defalutCache];
        [cache createFile:self.downloadInfo.filePath data:self.receiveData];
    }
    
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(hk_HttpDownloadStoped:success:)])
    {
        [self.delegate hk_HttpDownloadStoped:self success:YES];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

@end
