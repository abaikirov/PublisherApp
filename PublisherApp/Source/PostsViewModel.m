//
//  PostsViewModel.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/13/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "PostsViewModel.h"
#import "MUOPostsRequestManager.h"

#import "Post.h"
#import "NSDate+DateTools.h"

const int kPageSize = 20;
const int kSearchPageSize = 10;

@interface PostsViewModel ()

@property (nonatomic, strong) MUOPostsRequestManager* postsManager;

@property (nonatomic) int page;

@property (nonatomic) NSInteger totalPosts;


@end

@implementation PostsViewModel

#pragma mark - Initialization
-(instancetype)init {
   self = [super init];
   if (self) {
      self.postsManager = [MUOPostsRequestManager new];
      self.page = 1;
      self.lastPostID = nil;
   }
   return self;
}


#pragma mark - Pagination
-(void)resetPage {
   _lastPostID = nil;
   _page = 1;
}

- (void)setNextPage {
   _page++;
}

- (RACSignal *)fetchPosts {
   @weakify(self);
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [[self.postsManager fetchLatestPosts:_page lastPostID:_lastPostID] subscribeNext:^(NSArray *posts) {
         self.totalPosts = self.totalPosts + posts.count;
         self.total = posts.count == kPageSize ? self.totalPosts + 1 : self.totalPosts;
         [subscriber sendNext:posts];
         [subscriber sendCompleted];
      } error:^(NSError *error) {
         [subscriber sendError:error];
      }];
      return nil;
   }];
   
}
-(NSInteger)getPage {
   return self.page;
}

@end
