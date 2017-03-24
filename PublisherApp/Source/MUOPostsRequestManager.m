//
//  MUOPostsHTTPManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 8/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOPostsRequestManager.h"
#import "Post.h"
#import "PostsSessionManager.h"
@import DCKeyValueObjectMapping;

@interface MUOPostsRequestManager()

@property (nonatomic, strong) NSURLSessionDataTask* postsTask;

@property (nonatomic, strong) PostsSessionManager* sessionManager;

@end

@implementation MUOPostsRequestManager

- (PostsSessionManager *)sessionManager {
   _sessionManager = [PostsSessionManager sharedManager];
   [_sessionManager updateHeaders];
   return _sessionManager;
}

#pragma mark - Latest posts
- (RACSignal *)fetchLatestPosts:(NSInteger)page lastPostID:(NSNumber *) lastPostID {
   NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"per_page" : @(10), @"with_body" : @"true"}];
   
   if (lastPostID) {
      [params setObject:lastPostID forKey:@"last_item_id"];
   } else {
      [params setObject:@(page) forKey:@"page"];
   }
   return [self fetchPostsWithParameters:params];
}

- (RACSignal *) fetchPostsWithParameters:(NSDictionary *) parameters {
   @weakify(self);
   RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      self.postsTask = [self.sessionManager GET:@"posts" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
         
      } success:^(NSURLSessionDataTask *task, id responseObject) {
         DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:
                                            [Post class] andConfiguration:[Post parserConfiguration]] ;
         NSArray* posts = [parser parseArray:[responseObject valueForKey:@"posts"]];
         
         [subscriber sendNext:posts];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [subscriber sendError:error];
      }];
      
      return nil;
   }];
   return signal;
}

- (void) cancelPreviousTask {
   if (self.postsTask.state == NSURLSessionTaskStateRunning) {
      [self.postsTask cancel];
   }
}

- (RACSignal *)likePost:(NSNumber *)postID {
   @weakify(self);
   RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      
      NSString* url = [NSString stringWithFormat:@"posts/%@/like", postID];
      [self.sessionManager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
         
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

@end
