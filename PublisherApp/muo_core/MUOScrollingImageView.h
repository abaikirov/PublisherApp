//
//  MUOScrollingImageView.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/16/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollingImageViewDelegate <NSObject>

- (void) shouldEnableScrolling:(BOOL) enabled;

@end


@interface MUOScrollingImageView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak) id<ScrollingImageViewDelegate> imageViewDelegate;


- (void) restoreZoom;

@end
