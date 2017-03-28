//
//  BookmarksRequestManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "BookmarksRequestManager.h"
//#import "MUOUserSettings.h"
#import "PostsSessionManager.h"
@import ReactiveCocoa;

@interface BookmarksRequestManager()

//@property (nonatomic, strong) MUOUserSettings* userSettings;
@property (nonatomic, strong) PostsSessionManager* sessionManager;

@end

@implementation BookmarksRequestManager

#pragma mark - Bookmarks
- (RACSignal *)bookmarkPostsWithIDs:(NSArray *)postsID {
   @weakify(self);
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      
      NSDictionary* parameters = @{@"post_ids" : postsID};
      [self.sessionManager POST:@"bookmarked_posts" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress){
         
      } success:^(NSURLSessionDataTask *task, id responseObject) {
         [subscriber sendNext:responseObject];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [subscriber sendError:error];
      }];
      return nil;
   }];
   return signal;
}

-(RACSignal *)deleteBookmarkedPostsWithIDs:(NSArray *)postsID {
   @weakify(self);
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      
      NSDictionary* parameters = @{@"post_ids" : postsID};
      [self.sessionManager DELETE:@"bookmarked_posts" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
         [subscriber sendNext:responseObject];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [subscriber sendError:error];
      }];
      
      return nil;
   }];
   return signal;
}

-(RACSignal *)fetchBookmarks:(NSArray *) bookmarkIDs {
   /*@weakify(self);
   self.userSettings = [MUOUserSettings new];
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"with_body" : @"true", @"without_css" : @"true"}];
      if (bookmarkIDs) {
         [parameters setObject:bookmarkIDs forKey:@"post_ids"];
      }
      
      NSNumber* timeStamp = [self.userSettings bookmarksSyncTimestamp];
      if (!timeStamp) {
         timeStamp = [NSNumber numberWithUnsignedInteger:1446113672];
      }
      
      [parameters setObject:timeStamp forKey:@"timestamp"];
      
      [self.sessionManager POST:@"bookmarked_posts/sync" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
         
      } success:^(NSURLSessionDataTask *task, id responseObject) {
         DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:
                                            [MUOPost class] andConfiguration:[MUOPost parserConfiguration]];
         NSArray* posts = [parser parseArray:[responseObject valueForKey:@"posts"]];
         NSArray* deletedPostsIDs = [responseObject valueForKey:@"deleted_posts"];
         NSNumber* timeStamp = [responseObject valueForKey:@"timestamp"];
         
         RACTuple* tuple = RACTuplePack(posts, deletedPostsIDs);
         
         [self.userSettings setBookmarksSyncTimestamp:timeStamp];
         [subscriber sendNext:tuple];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [subscriber sendError:error];
      }];
      
      
      return nil;
   }];
   return signal;*/
   return nil;
}



@end
