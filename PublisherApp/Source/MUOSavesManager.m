//
//  MUOSavesManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 8/20/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

@import SDWebImage;
#import "MUOSavesManager.h"
#import "MUOSavedPost.h"
#import "Post.h"
#import "MUOFileCache.h"
#import "Realm.h"
#import "MUODownloadPool.h"
#import "SDWebImagePrefetcher+MUO.h"
#import "BookmarksRequestManager.h"


@interface MUOSavesManager()

@property (nonatomic, strong) BookmarksRequestManager* bookmarksManager;

@property (nonatomic, strong) RACSignal* fetchSignal;
@property (nonatomic, strong) RACReplaySubject* finishSignal;


@property (nonatomic, strong) NSArray* signalsPool;

@end

@implementation MUOSavesManager

-(instancetype)init
{
   self = [super init];
   if (self) {
      self.bookmarksManager = [BookmarksRequestManager new];
      self.downloadPool = [MUODownloadPool new];
   }
   return self;
}

- (void)setBookmarksCountObserver:(id<BookmarksCountObserver>)bookmarksCountObserver {
   _bookmarksCountObserver = bookmarksCountObserver;
   [_bookmarksCountObserver bookmarksCountChanged:[self bookmarksCount]];
}

#pragma mark - Fetching saves
-(NSArray *)getBookmarks {
   RLMResults *allSaves = [[MUOSavedPost allObjects] objectsWhere:@"isBookmarked=YES"];
   NSMutableArray *array = [NSMutableArray arrayWithCapacity:allSaves.count];
   for (RLMObject *object in allSaves) {
      [array addObject:object];
   }
   return array;
}

- (NSArray *)getOfflinePosts {
   RLMResults *allSaves = [[MUOSavedPost allObjects] objectsWhere:@"isOfflineSaved=YES"];
   NSMutableArray *array = [NSMutableArray arrayWithCapacity:allSaves.count];
   for (RLMObject *object in allSaves) {
      [array addObject:object];
   }
   return array;

}

-(MUOSavedPost *)savedPostWithID:(NSInteger)postID {
   MUOSavedPost* result = [MUOSavedPost objectForPrimaryKey:[NSNumber numberWithInteger:postID]];
   return result;
}

#pragma mark - Loading offline posts
-(RACSignal *)loadLatestPosts:(NSArray *)posts {
   [self clearPostsCache];
   [self prefetchPostAvatars:posts];
   
   self.downloadInProgress = YES;
   [self.downloadPool startNewDownload];
   self.signalsPool = [self downloadSignalsForPosts:posts];
   
   self.downloadFinishedSignal = [RACReplaySubject subject];
   @weakify(self);
   [[RACSignal concat:self.signalsPool] subscribeNext:^(Post* cachedPost) {
      @strongify(self);
      
      [cachedPost replaceRemoteUrlsWithLocal];
      [self saveToRealm:cachedPost isBookmarked:NO isOfflineSaved:YES];
      
      [self.downloadFinishedSignal sendNext:cachedPost];
   } error:^(NSError *error) {
      @strongify(self);
      self.downloadInProgress = NO;
      [self.downloadPool finishDownload];
   } completed:^{
      @strongify(self);
      self.downloadInProgress = NO;
      [self.downloadPool finishDownload];
      [self.downloadFinishedSignal sendCompleted];
   }];
   
   return self.downloadFinishedSignal;
}

- (void) prefetchPostAvatars:(NSArray *) posts {
   [SDWebImagePrefetcher prefetchAvatarsForPosts:posts];
}

- (NSArray *) downloadSignalsForPosts:(NSArray*) posts {
   NSMutableArray* result = [NSMutableArray new];
   for (Post* post in posts) {                //We shouldn't download post that has been downloaded already
      RLMResults *savedPosts = [MUOSavedPost objectsWhere:@"ID=%@",post.ID];
      if (savedPosts.count == 0) {
         [result addObject:[self.downloadPool downloadImagesForPost:post]];
      } else {
         MUOSavedPost* savedPost = (MUOSavedPost*)[savedPosts firstObject];
         [self updateInRealm:savedPost isBookmarked:savedPost.isBookmarked isOfflineSaved:YES];
      }
   }
   return result;
}

#pragma mark - Saving posts
- (RACSignal *)handleBookmark:(Post *)post postID:(NSNumber *)postID {
   RACReplaySubject* resultSignal = [RACReplaySubject subject];
   RLMResults *savedPosts = [MUOSavedPost objectsWhere:@"ID=%@", postID];
   if (savedPosts.count == 0) { //Bookmark posts
      return [self savePost:post];
   } else {
      [self deleteSavedPostWithID:postID shouldSync:YES];
      [resultSignal sendNext:@(NO)];
      [resultSignal sendCompleted];
   }
   return resultSignal;
}

- (BOOL)bookmarkExists:(NSNumber *)postID {
   RLMResults *savedPosts = [MUOSavedPost objectsWhere:@"ID=%@", postID];
   BOOL result = NO;
   if (savedPosts.count != 0) {
      MUOSavedPost* savedPost = [savedPosts lastObject];
      return savedPost.isBookmarked;
   }
   return result;
}

- (NSInteger)bookmarksCount {
   RLMResults* bookmarks = [MUOSavedPost objectsWhere:@"isBookmarked=YES"];
   return bookmarks.count;
}

-(RACSignal *)savePost:(Post *)post {
   RACSignal* imagesSignal = [self.downloadPool downloadImagesForPost:post];
   self.finishSignal = [RACReplaySubject subject];
   
   RLMResults *savedPosts = [MUOSavedPost objectsWhere:@"ID=%@",post.ID];
   if(savedPosts.count == 0) {
      [self saveToRealm:post isBookmarked:YES isOfflineSaved:NO];
      [self bookmarkPostsWithIDs:@[post.ID]];
      [self.finishSignal sendNext:@(YES)];
      
      //Downloading images
      @weakify(self);
      [imagesSignal subscribeNext:^(Post* post) {
         @strongify(self);
         
         [post replaceRemoteUrlsWithLocal];
         [self saveToRealm:post isBookmarked:YES isOfflineSaved:NO];
         [self.downloadPool finishDownload];
         [self.finishSignal sendCompleted];
      } error:^(NSError *error) {
         @strongify(self);
         [self.finishSignal sendError:error];
      }];
   }
   else {                    //If post is already saved
      MUOSavedPost* postToSave = [savedPosts lastObject];
      if ([postToSave isBookmarked] == NO) { //If post is saved but not bookmarked, we just bookmark it
         [self saveToRealm:post isBookmarked:YES isOfflineSaved:YES];
         [self bookmarkPostsWithIDs:@[@(postToSave.ID)]];
         [self.finishSignal sendNext:@(YES)];
         [self.finishSignal sendCompleted];
      } else {
         [self.finishSignal sendError:nil];
      }
   }
   
   return self.finishSignal;
}

#pragma mark - Realm related methods
-(void) updateInRealm:(MUOSavedPost *) post isBookmarked:(BOOL) bookmarked isOfflineSaved:(BOOL) isOfflineSaved {
   RLMRealm *realm = [RLMRealm defaultRealm];
   [realm transactionWithBlock:^{
      post.isBookmarked = bookmarked;
      post.isOfflineSaved = isOfflineSaved;
      [MUOSavedPost createOrUpdateInRealm:realm withValue:post];
      [self.bookmarksCountObserver bookmarksCountChanged:[self bookmarksCount]];
   }];
}

-(void) saveToRealm:(Post*) post isBookmarked:(BOOL) bookmarked isOfflineSaved:(BOOL) isOfflineSaved {
   MUOSavedPost* postToSave = [post postToSave:bookmarked];
   [self updateInRealm:postToSave isBookmarked:bookmarked isOfflineSaved:isOfflineSaved];
}

- (void) deleteSavedPostWithID:(NSNumber *) postID shouldSync:(BOOL) shouldSync {
   RLMRealm* realm = [RLMRealm defaultRealm];
   MUOSavedPost* postToDelete = [MUOSavedPost objectsWhere:@"ID=%@", postID].firstObject;
   if (postToDelete) {
      if (postToDelete.isOfflineSaved) {     //Don't delete offline post. Just remove from bookmarks
         [self updateInRealm:postToDelete isBookmarked:NO isOfflineSaved:YES];
      } else {
         [realm transactionWithBlock:^{
            [realm deleteObject:postToDelete];
            [self.bookmarksCountObserver bookmarksCountChanged:[self bookmarksCount]];
         }];
         [[MUOFileCache sharedCache] clearCacheDirectoryForPostID:postID.integerValue];
      }
      if (shouldSync) {
         [self deleteBookmarksWithIDs:@[postID]];
      }
   }
}

#pragma mark - Server interaction
- (void) bookmarkPostsWithIDs:(NSArray *) postsIDs {
   /*if ([MUOUserSession sharedSession].authToken) {    //If user is authorized, send a bookmark ID to the server
      [[self.bookmarksManager bookmarkPostsWithIDs:postsIDs] subscribeNext:^(id x) {
         DLog(@"Bookmark added succsefully");
      } error:^(NSError *error) {
         DLog(@"Error while bookmarking");
      }];
   }*/
}

- (void) deleteBookmarksWithIDs:(NSArray *) postsIDs {
   /*if ([MUOUserSession sharedSession].authToken) {
      [[self.bookmarksManager deleteBookmarkedPostsWithIDs:postsIDs] subscribeNext:^(id x) {
         DLog(@"Bookmark deleted");
      } error:^(NSError *error) {
         DLog(@"Error deleting bookmark");
      }];
   }*/
}


#pragma mark - Offline
-(void)clearPostsCache {
   RLMResults* cachedPosts = [[MUOSavedPost objectsWhere:@"isOfflineSaved=YES"] objectsWhere:@"isBookmarked=NO"];
   while (cachedPosts.count > 0) {
      MUOSavedPost *savedPost = cachedPosts.firstObject;
      NSInteger postID = savedPost.ID;
      RLMRealm* realm = [RLMRealm defaultRealm];
      [realm transactionWithBlock:^{
         [realm deleteObject:savedPost];
      }];
      [[MUOFileCache sharedCache] clearCacheDirectoryForPostID:postID];
   }
}

-(void) removeCacheForPost:(Post *) post {
   [[MUOFileCache sharedCache] clearCacheDirectoryForPostID:[post.ID integerValue]];
   [post clearLocalURLs];
}


#pragma mark - Realm
-(void)performRealmMigrationIfNecessary {
   RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
   // Set the new schema version. This must be greater than the previously used
   // version (if you've never set a schema version before, the version is 0).
   int currentSchemaVersion = 4;
   config.schemaVersion = currentSchemaVersion;
   
   // Set the block which will be called automatically when opening a Realm with a
   // schema version lower than the one set above
   config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
      // Old schema version is 1
      if (oldSchemaVersion < currentSchemaVersion) {
         // Nothing to do!
         // Realm will automatically detect new properties and removed properties
         // And will update the schema on disk automatically
      }
   };
   
   // Tell Realm to use this new configuration object for the default Realm
   [RLMRealmConfiguration setDefaultConfiguration:config];
}


@end
