//
//  NSDictionary+HKURL.h
//  HookSDK
//
//  Created by arlin on 17/3/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HKURL)

- (NSString *)toURL;

+ (instancetype)fromURL:(NSString *)URL;

@end
