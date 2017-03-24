//
//  LikesManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface LikesManager : NSObject

- (BOOL) likePost:(Post *) post;
- (BOOL) postIsLiked:(Post *) post;

@end
