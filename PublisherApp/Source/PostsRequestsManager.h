//
//  PostsRequestsManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/23/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;
@import ReactiveCocoa;
@class DCParserConfiguration;
@class PostsSessionManager;

@interface PostsRequestsManager : NSObject

@property (nonatomic, strong) NSURLSessionDataTask* postsTask;
@property (nonatomic, strong) PostsSessionManager* sessionManager;

- (RACSignal *) fetchPostsWithParameters:(NSDictionary *) parameters;


+ (Class) postClass;
+ (DCParserConfiguration*) parserConfiguration;

- (RACSignal *) fetchLatestPosts:(NSInteger)page lastPostID:(NSNumber *) lastPostID;
- (RACSignal *) likePost:(NSNumber*) postID;
- (RACSignal *) fetchPostByID:(NSString *)ID;

@end
