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
#import "CoreContext.h"

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
- (RACSignal *)fetchLatestPosts:(NSInteger)page lastPostID:(NSNumber *) lastPostID lastPostDate:(NSDate *)lastDate {
   NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"per_page" : @(10), @"with_body" : @"true"}];
   
   if (lastDate) {
      /*NSDateFormatter* formatter = [NSDateFormatter new];
      formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
      NSString* date = [formatter stringFromDate:lastDate];
      [params setObject:date forKey:@"last_item_datetime"];*/
      [params setObject:lastPostID forKey:@"last_item_id"];
   } else {
      [params setObject:@(page) forKey:@"page"];
   }
   return [self fetchPostsWithParameters:params];
}

- (RACSignal *)fetchPostsByCategoryID:(NSNumber *)categoryID lastPostID:(NSNumber *)lastPostID lastPostDate:(NSDate *)lastDate {
   NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"cats" : categoryID}];
   if (lastDate) {
      /*NSDateFormatter* formatter = [NSDateFormatter new];
      formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
      NSString* date = [formatter stringFromDate:lastDate];
      [params setObject:date forKey:@"last_item_datetime"];*/
      [params setObject:lastPostID forKey:@"last_item_id"];
   }
   return [self fetchPostsWithParameters:params];
}

- (RACSignal *) fetchPostsWithParameters:(NSDictionary *) parameters {
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
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
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
   @weakify(self);
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
      @strongify(self);
      NSDictionary* parameters = nil;
      NSString* postEncodedURL = [ID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
      NSMutableString* url = [NSMutableString stringWithFormat:@"posts/?url=%@", postEncodedURL];
      if (![ID hasSuffix:@"/"]) {
         [url appendString:@"%2F"];
      }
      [self.sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
         
      } success:^(NSURLSessionDataTask *task, id responseObject){
         //Check if content exists
         NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
         if (response.statusCode == 204) {
            [subscriber sendError:nil];
         } else {
            DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[self.class postClass] andConfiguration:[self.class parserConfiguration]];
            Post *post = [parser parseDictionary:responseObject];
            
            [subscriber sendNext:post];
         }
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
   [self.sessionManager.requestSerializer setValue:[CoreContext sharedContext].accessToken forHTTPHeaderField:@"X-Auth-Token"];
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
