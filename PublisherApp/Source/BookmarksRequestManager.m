//
//  BookmarksRequestManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "BookmarksRequestManager.h"
#import "PostsSessionManager.h"
#import "CoreContext.h"
#import "Post.h"
@import DCKeyValueObjectMapping;
@import ReactiveCocoa;

@interface BookmarksRequestManager()
@property (nonatomic, strong) PostsSessionManager* sessionManager;
@end

@implementation BookmarksRequestManager

- (PostsSessionManager *)sessionManager {
   _sessionManager = [PostsSessionManager sharedManager];
   [_sessionManager updateHeaders];
   return _sessionManager;
}

#pragma mark - Syncing
- (RACSignal *)syncBookmarks {
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
   @weakify(self);
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [self.sessionManager GET:@"bookmarks" parameters:nil progress:nil success:^(NSURLSessionDataTask* task, id responseObject) {
         DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:
                                            [Post class] andConfiguration:[Post parserConfiguration]] ;
         NSArray* posts = [parser parseArray:responseObject];
         [subscriber sendNext:posts];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [subscriber sendError:error];
      }];
      return nil;
   }];
}


#pragma mark - Bookmarks
- (void)addBookmark:(NSString *)postID {
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
   NSString* url = [NSString stringWithFormat:@"bookmarks/%@", postID];
   
   [self.sessionManager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
      
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
   }];
}

- (void) deleteBookmark:(NSString*) postID {
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
   NSString* url = [NSString stringWithFormat:@"bookmarks/%@", postID];
   [self.sessionManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
      
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
   }];
}


@end
