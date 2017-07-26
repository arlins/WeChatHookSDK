#import "HKHttpDownloadCache.h"

@interface HKHttpDownloadCache ()

- (NSString *)defaultCachePath;

@end

@implementation HKHttpDownloadCache

+ (instancetype)defalutCache
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        
    }
    
    return self;
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)createFile:(NSString *)filePath data:(NSData *)data;
{
    [data writeToFile:filePath atomically:YES];
}

- (void)deleteFile:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (BOOL)isFileExist:(NSString *)filePath
{
    BOOL isDirectory = NO;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                                            isDirectory:&isDirectory];
    
    return (isFileExist && !isDirectory);
}

- (NSString *)defaultCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"Download"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    return path;
}

@end
