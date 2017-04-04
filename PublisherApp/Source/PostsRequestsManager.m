//
//  PostsRequestsManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/23/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import ReactiveCocoa;
#import "PostsRequestsManager.h"
#import "Post.h"
@import DCKeyValueObjectMapping;
#import "PostsSessionManager.h"

@implementation PostsRequestsManager

- (PostsSessionManager *)sessionManager {
   _sessionManager = [PostsSessionManager sharedManager];
   [_sessionManager updateHeaders];
   return _sessionManager;
}

+ (Class)postClass {
   return [Post class];
}

+ (DCParserConfiguration*) parserConfiguration {
   return [Post parserConfiguration];
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

- (RACSignal *)fetchPostsByCategoryID:(NSNumber *)categoryID lastPostID:(NSNumber *)lastPostID {
   NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"cats" : categoryID}];
   if (lastPostID) {
      [params setObject:lastPostID forKey:@"last_item_id"];
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
                                            [self.class postClass] andConfiguration:[self.class parserConfiguration]] ;
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


-(RACSignal *)fetchPostByID:(NSString *)ID{
   NSLog(@"fetchPostById %ld", (long)ID);
   @weakify(self);
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
      @strongify(self);
      NSDictionary* parameters = nil;
      /*if ([MUOUserSession sharedSession].remoteCSS) {
         parameters = @{@"without_css" : @"true"};
      }*/
      
      NSString* postEncodedURL = [ID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
      NSString* url = [NSString stringWithFormat:@"posts/?url=%@", postEncodedURL];
      [self.sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
         
      } success:^(NSURLSessionDataTask *task, id responseObject){
         DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[self.class postClass] andConfiguration:[self.class parserConfiguration]];
         Post *post = [parser parseDictionary:responseObject];
         
         [subscriber sendNext:post];
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
