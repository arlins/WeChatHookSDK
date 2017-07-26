#import <Foundation/Foundation.h>

@class HKHttpDownloader;

@interface HKHttpDownloadInfoItem : NSObject

@property (nonatomic, copy) NSString *tid;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) long long fileSize;

@end

@protocol HKHttpDownloaderDelegate <NSObject>

@optional
- (void)hk_HttpDownloadStarted:(HKHttpDownloader *)downloader;
- (void)hk_HttpDownloadStoped:(HKHttpDownloader *)downloader success:(BOOL)success;
- (void)hk_HttpDownloadProcess:(HKHttpDownloader *)downloader process:(float)process;

@end


@interface HKHttpDownloader : NSObject

@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) id<HKHttpDownloaderDelegate> delegate;
@property (nonatomic, copy) HKHttpDownloadInfoItem *downloadInfo;

- (void)start;
- (void)stop;

@end
