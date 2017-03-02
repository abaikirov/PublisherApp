//
//  MUOPostsHTTPManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 8/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MUOPostsRequestManager : NSObject

- (RACSignal *)fetchLatestPosts:(NSInteger)page lastPostID:(NSNumber *) lastPostID;

@end
