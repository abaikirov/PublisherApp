//
//  PostsViewModel.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/13/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "PostsViewModel.h"
#import "MUOSavesManager.h"
#import "Post.h"
#import "CoreContext.h"

static int pageSize = 20;
@interface PostsViewModel ()

@property (nonatomic) int page;

@end

@implementation PostsViewModel
@synthesize total = _total;

#pragma mark - Initialization
-(instancetype)init {
   self = [super init];
   if (self) {
      self.postsManager = [PostsRequestsManager new];
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


-(NSInteger)getPage {
   return self.page;
}


- (RACSignal *)fetchPosts {
   @weakify(self);
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [[self.postsManager fetchLatestPosts:_page lastPostID:_lastPostID] subscribeNext:^(NSArray *posts) {
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

-(void)fetchSavedPosts {
   NSArray* savedPosts = [[CoreContext sharedContext].savesManager getOfflinePosts];
   NSMutableArray* posts = [NSMutableArray new];
   for (MUOSavedPost *savedPost in savedPosts) {
      Post* post = [Post new];
      [post fillWithSavedPost:savedPost];
      [posts addObject:post];
   }
   NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postDate" ascending:NO];
   self.savedPosts = [posts sortedArrayUsingDescriptors:@[sortDescriptor]];
}


@end
