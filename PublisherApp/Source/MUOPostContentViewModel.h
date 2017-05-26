//
//  SPLMPostContentViewModel.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
@import ReactiveCocoa;

@interface MUOPostContentViewModel : NSObject

@property (strong, nonatomic) NSNumber *postId;
@property (strong, nonatomic) NSString* postSlug;
@property (strong, nonatomic) Post *post;

- (RACSignal *) loadPost;
- (RACSignal *) loadSavedPost;

@end
