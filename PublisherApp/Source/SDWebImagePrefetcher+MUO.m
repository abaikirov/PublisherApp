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
      if (i % 5 == 0) { //Preload featured image for large cells
         if (post.featuredImage.featured != nil){
            [urls addObject:post.featuredImage.featured];
         }
      }
      //Preload middle images for all posts
      if (post.featuredImage.middle != nil) {
         [urls addObject:post.featuredImage.middle];
      }
   }
   
   //Downloading with manager, because SDWebImagePrefetcher not working :)
   for (NSURL* imageURL in urls) {
      [[SDWebImageManager sharedManager] loadImageWithURL:imageURL options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
         [[SDWebImageManager sharedManager] saveImageToCache:image forURL:imageURL];
      }];
   }
}

@end
