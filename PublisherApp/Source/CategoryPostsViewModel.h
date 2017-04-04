//
//  CategoryPostsViewModel.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "PostsViewModel.h"

@class PostCategory;
@interface CategoryPostsViewModel : PostsViewModel

- (void)appendFilter:(PostCategory *)filter;

@end
