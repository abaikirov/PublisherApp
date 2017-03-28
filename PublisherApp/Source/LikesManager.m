//
//  LikesManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "LikesManager.h"
#import "PostsRequestsManager.h"

@interface LikesManager()

@property (nonatomic, strong) NSMutableArray* likedPosts;
@property (nonatomic, strong) PostsRequestsManager* postsManager;

@end

@implementation LikesManager

- (instancetype)init {
   self = [super init];
   if (self) {
      self.likedPosts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"likes"] mutableCopy];
      if (self.likedPosts == nil) {
         self.likedPosts = [NSMutableArray new];
      }
   }
   return self;
}

#pragma mark - Likes

- (BOOL)likePost:(Post *)post {
   if ([self.likedPosts containsObject:post.ID]) {
      return NO;
   }
   if (!self.postsManager) {
      self.postsManager = [PostsRequestsManager new];
   }
   [[self.postsManager likePost:post.ID] subscribeNext:^(id x) {
      
   }];
   [self.likedPosts addObject:post.ID];
   post.likesCount = @(post.likesCount.integerValue + 1);
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self saveLikes];
   });
   return YES;
}

- (BOOL)postIsLiked:(Post *)post {
   if ([self.likedPosts containsObject:post.ID]) {
      return YES;
   }
   return NO;
}

- (void) saveLikes {
   [[NSUserDefaults standardUserDefaults] setObject:self.likedPosts forKey:@"likes"];
}

@end
