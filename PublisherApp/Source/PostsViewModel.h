//
//  PostsViewModel.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/13/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostsRequestsManager.h"




@protocol ViewModelPaginator <NSObject>

@property (nonatomic) NSInteger total;

- (NSInteger) getPage;
- (void) resetPage;
- (void) setNextPage;


@end

@class MUOCategory;
@interface PostsViewModel : NSObject<ViewModelPaginator>

@property (nonatomic, strong) PostsRequestsManager* postsManager;
@property (nonatomic) NSInteger totalPosts;

@property (nonatomic, strong) NSArray* savedPosts;
@property (nonatomic) NSNumber* lastPostID;
@property (nonatomic) NSDate* lastPostDate;

- (RACSignal *) fetchPosts;
- (void) fetchSavedPosts;


@end
