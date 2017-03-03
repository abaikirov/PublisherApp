//
//  SDWebImagePrefetcher+MUO.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/29/16.
//  Copyright © 2016 MakeUseOf. All rights reserved.
//
@import SDWebImage;

@interface SDWebImagePrefetcher (MUO)

+ (void) prefetchAvatarsForPosts:(NSArray*) posts;

@end
