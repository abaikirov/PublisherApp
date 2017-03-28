//
//  MUOFileCache.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/1/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOFileCache.h"

@implementation MUOFileCache

+(instancetype)sharedCache {
   static MUOFileCache *cache;
   static dispatch_once_t once_t;
   dispatch_once(&once_t, ^
                 {
                    cache = [MUOFileCache new];
                 });
   return cache;
}


-(void) clearCacheDirectoryForPostID:(NSInteger) postID {
   NSError* error;
   NSString* directory = [self cacheDirectoryForPostID:postID];
   [[NSFileManager defaultManager] removeItemAtPath:directory error:&error];
   if (!error) {
      NSLog(@"%@ cleared", [directory lastPathComponent]);
   }
}

-(NSString*) cacheDirectoryForPostID:(NSInteger) postID {
   NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   NSString* postCacheFolder = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"post_%ld", (long)postID]];
   
   BOOL isDir = NO;
   NSError* error = nil;
   
   NSFileManager* fileManager = [NSFileManager defaultManager];
   if (![fileManager fileExistsAtPath:postCacheFolder isDirectory:&isDir] && isDir == NO) {
      [fileManager createDirectoryAtPath:postCacheFolder withIntermediateDirectories:NO attributes:nil error:&error];
   }
   
   if (error) {
      return nil;
   }
   
   return postCacheFolder;
}

- (NSString *)cssFilePath {
   NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"css.txt"];
   return filePath;
}


- (void)excludeFilesFromBackup {
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
   NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
   NSURL *URL;
   NSString *completeFilePath;
   for (NSString *file in documents) {
      completeFilePath = [NSString stringWithFormat:@"%@/%@", basePath, file];
      URL = [NSURL fileURLWithPath:completeFilePath];
      [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
   }
}

@end
