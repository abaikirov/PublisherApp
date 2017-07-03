//
//  CategoryPostsViewModel.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "CategoryPostsViewModel.h"
#import "PostsRequestsManager.h"
#import "Post.h"

static int pageSize = 20;
@interface CategoryPostsViewModel()

@property (nonatomic) PostCategory *selectedCategory;

@end

@implementation CategoryPostsViewModel

- (instancetype)init {
   self = [super init];
   if (self) {
      self.postsManager = [PostsRequestsManager new];
   }
   return self;
}

- (void)appendFilter:(PostCategory *)filter {
   self.selectedCategory = filter;
   self.total = 0;
}


-(RACSignal *)fetchPosts {
   @weakify(self);
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [[self.postsManager fetchPostsByCategoryID:self.selectedCategory.id lastPostID:self.lastPostID lastPostDate:self.lastPostDate] subscribeNext:^(NSArray* posts) {
         self.totalPosts = self.totalPosts + posts.count;
         self.total = posts.count == pageSize ? self.totalPosts + 1 : self.totalPosts;
         [subscriber sendNext:posts];
         [subscriber sendCompleted];
      } error:^(NSError *error) {
         [subscriber sendError:error];
      }];
      return nil;
   }];
}

@end
