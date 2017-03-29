//
//  MUOSavesManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 8/20/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;
@class MUOSavedPost;
@class MUODownloadPool;
@import ReactiveCocoa;
@interface MUOSavesManager : NSObject

typedef enum {
   Latest10,
   Last3Days
} DownloadPeriod;

//Used for posts downloading
@property (nonatomic, strong) RACReplaySubject* downloadFinishedSignal;
@property (nonatomic, strong) MUODownloadPool* downloadPool;
@property (nonatomic) BOOL downloadInProgress;

/**
 Bookmark post if it's not
 Delete bookmark if it exists
 **/
- (RACSignal*) handleBookmark:(Post*) post postID:(NSNumber *) postID;

- (BOOL) bookmarkExists:(NSNumber*) postID;
- (NSInteger) bookmarksCount;

/**
 Get all bookmarks
 **/
- (NSArray *) getBookmarks;

/**
 Get posts saved for offline
 **/
- (NSArray *) getOfflinePosts;
- (RACSignal *) loadLatestPosts:(NSArray *) posts;
- (MUOSavedPost *) savedPostWithID:(NSInteger) postID;

/**
 Delete saved post
 */
- (void) deleteSavedPostWithID:(NSNumber *) postID shouldSync:(BOOL) shouldSync;
- (void) saveToRealm:(Post*) post isBookmarked:(BOOL) bookmarked isOfflineSaved:(BOOL) isOfflineSaved;


/**
 Realm migration
 **/
- (void) performRealmMigrationIfNecessary;

@end
