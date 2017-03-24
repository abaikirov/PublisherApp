//
//  MUOFileCache.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/1/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUOFileCache : NSObject

+ (instancetype) sharedCache;

- (void) clearCacheDirectoryForPostID:(NSInteger) postID;
- (NSString*) cacheDirectoryForPostID:(NSInteger) postID;

- (NSString *) cssFilePath;

- (void) excludeFilesFromBackup;

@end
