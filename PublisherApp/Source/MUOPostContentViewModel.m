//
//  SPLMPostContentViewModel.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "MUOPostContentViewModel.h"
#import "PostsRequestsManager.h"
#import "MUOHtmlEditor.h"
#import "MUOSavesManager.h"
#import "MUOSavedPost.h"
#import "CoreContext.h"

@interface MUOPostContentViewModel ()
@property (nonatomic, strong) PostsRequestsManager* postsManager;
@end

@implementation MUOPostContentViewModel

- (instancetype)init{
   self = [super init];
   if(self) {
      self.postsManager = [PostsRequestsManager new];
   }
   return self;
}

- (RACSignal *)loadPost {
   @weakify(self);
   NSString* fetchIdentifier = _postId ? [_postId stringValue] : _postSlug;
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [[self.postsManager fetchPostByID:fetchIdentifier] subscribeNext:^(Post *post) {
         [subscriber sendNext:post];
         [subscriber sendCompleted];
      } error:^(NSError *error) {
         [subscriber sendError:error];
      }];
      return nil;
   }];
}

- (RACSignal *) loadSavedPost {
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      MUOSavedPost* savedPost = [[CoreContext sharedContext].savesManager savedPostWithID:[_postId integerValue]];
      if (savedPost != nil) {
         Post* postToDisplay = [Post new];
         [postToDisplay fillWithSavedPost:savedPost];
         [subscriber sendNext:postToDisplay];
         [subscriber sendCompleted];
      }
      return nil;
   }];
}

@end
