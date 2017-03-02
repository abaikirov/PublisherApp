//
//  SDWebImagePrefetcher+MUO.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/29/16.
//  Copyright © 2016 MakeUseOf. All rights reserved.
//

#import "SDWebImagePrefetcher+MUO.h"
#import "Post.h"

@implementation SDWebImagePrefetcher (MUO)

+ (void)prefetchAvatarsForPosts:(NSArray *)posts {
   NSMutableArray* urls = [NSMutableArray new];
   for (int i = 0; i < posts.count; i++) {
      Post* post = posts[i];
      if (i % 5 == 0) {
         if (post.featuredImage.featured != nil) [urls addObject:post.featuredImage.featured];
      } else {
         if (post.featuredImage.middle != nil) [urls addObject:post.featuredImage.middle];
      }
   }
   [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
}

@end
