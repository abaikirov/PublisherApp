//
//  PostsViewModel.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/13/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface PostsViewModel : NSObject



@property (nonatomic) NSInteger total;
@property (nonatomic) NSNumber* lastPostID;

- (NSInteger) getPage;

- (void) resetPage;
- (void) setNextPage;

- (RACSignal *) fetchPosts;


@end
