//
//  MUOPostsHTTPManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 8/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

@import ReactiveCocoa;

@interface MUOPostsRequestManager : NSObject

- (RACSignal *)fetchLatestPosts:(NSInteger)page lastPostID:(NSNumber *) lastPostID;
- (RACSignal *) likePost:(NSNumber*) postID;

@end
