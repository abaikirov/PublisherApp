//
//  CategoriesRequestsManager.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 4/3/17.
//
//

@import AFNetworking;
@import DCKeyValueObjectMapping;
#import "CategoriesRequestsManager.h"
#import "PostsSessionManager.h"
#import "Post.h"

@interface CategoriesRequestsManager()

@property (nonatomic, strong) PostsSessionManager* sessionManager;

@end

@implementation CategoriesRequestsManager

- (PostsSessionManager *)sessionManager {
   _sessionManager = [PostsSessionManager sharedManager];
   [_sessionManager updateHeaders];
   return _sessionManager;
}


#pragma mark - Requests
- (RACSignal *)fetchCategories {
   @weakify(self);
   RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
      @strongify(self);
      [self.sessionManager GET:@"categories" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
         
      } success:^(NSURLSessionDataTask *task, id responseObject) {
         DCKeyValueObjectMapping* parser = [DCKeyValueObjectMapping mapperForClass:[PostCategory class]];
         NSArray *categories = [parser parseArray:responseObject];
         
         [subscriber sendNext:categories];
         [subscriber sendCompleted];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [subscriber sendError:error];
      }];
      
      return nil;
   }];
   return signal;
}

@end
