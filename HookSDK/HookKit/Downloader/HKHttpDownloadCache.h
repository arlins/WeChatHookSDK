#import <Foundation/Foundation.h>

@interface HKHttpDownloadCache : NSObject

+ (instancetype)defalutCache;

- (NSString *)defaultCachePath;

- (void)createFile:(NSString *)filePath data:(NSData *)data;
- (void)deleteFile:(NSString *)filePath;
- (BOOL)isFileExist:(NSString *)filePath;

@end
