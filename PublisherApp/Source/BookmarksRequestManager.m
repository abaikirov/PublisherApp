//
//  BookmarksRequestManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "BookmarksRequestManager.h"
#import "PostsSessionManager.h"

@interface BookmarksRequestManager()

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
   return nil;
}



@end
