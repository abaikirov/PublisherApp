//
//  PostRepresentable.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/15/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@protocol PostRepresentable <NSObject>

+ (NSString*) cellID;
+ (NSString*) nibName;

- (void)fillWithPost:(Post *)post labelFrame:(CGRect)labelFrame;

@optional
+ (CGRect)labelFrame:(Post *)post cellSize:(CGSize)cellSize;
+ (CGRect)labelHeightForPost:(Post *)post left:(BOOL)left imageSize:(CGSize)imageSize;


@end
