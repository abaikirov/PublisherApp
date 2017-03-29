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

@interface SavesViewModel ()

@property (nonatomic, strong) BookmarksRequestManager* bookmarksManager;

@end

@implementation SavesViewModel

-(void) fetchAndSyncSaves{
    [self loadSavesFromCache];
    
    /*if ([MUOUserSession sharedSession].authToken) {
        [self synchronizeSaves];
    }*/
}

- (void) loadSavesFromCache {
    NSArray* saves = [[CoreContext sharedContext].savesManager getBookmarks];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.saves = [[saves sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
}


@end
