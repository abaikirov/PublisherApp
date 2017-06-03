//
//  SPLMSavesViewModel.m
//  MakeUseOf
//
//  Created by AZAMAT on 5/12/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "SavesViewModel.h"
#import "CoreContext.h"
#import "MUOSavedPost.h"
#import "Post.h"
#import "BookmarksRequestManager.h"
@import ReactiveCocoa;

@interface SavesViewModel ()
@property (nonatomic, strong) BookmarksRequestManager* bookmarksManager;
@end

@implementation SavesViewModel

- (BookmarksRequestManager *)bookmarksManager {
   if (!_bookmarksManager) {
      _bookmarksManager = [BookmarksRequestManager new];
   }
   return _bookmarksManager;
}

- (NSMutableArray *)saves {
   if (_saves == nil) {
      _saves = [NSMutableArray new];
   }
   return _saves;
}

#pragma mark - Fetching saves
- (RACSignal*) syncSaves {
   @weakify(self);
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      @strongify(self);
      [[self.bookmarksManager syncBookmarks] subscribeNext:^(NSArray* posts) {
         for (Post* post in posts) {
            MUOSavedPost* postToSave = [post postToSave:YES];
            if (![self.saves containsObject:postToSave]) [self.saves addObject:postToSave];
         }
         [subscriber sendNext:posts];
         [subscriber sendCompleted];
      }];
      return nil;
   }];
}

- (void) loadSavesFromCache {
    NSArray* saves = [[CoreContext sharedContext].savesManager getBookmarks];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.saves = [[saves sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
}


@end
