//
//  MUOScrollingImageView.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/16/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOScrollingImageView.h"
#import "UIImage+MUO.h"

@interface MUOScrollingImageView()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;

@end

@implementation MUOScrollingImageView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScrollView];
    }
    return self;
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self setupActivityIndicator];
}

#pragma mark - Setup
- (void) setupScrollView {
    self.delegate = self;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 6.0f;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.contentSize = self.bounds.size;
}

- (void) setupActivityIndicator {
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.frame = CGRectMake(self.frame.size.width / 2 - 18.5, self.frame.size.height / 2 - 18.5, 37, 37);
    
    [self addSubview:self.activityView];
    
    [self bringSubviewToFront:self.activityView];
    [self.activityView startAnimating];
    
}

- (void) setupImageViewWithImage:(UIImage *) image {
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = [self frameForImageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:self.imageView];
    self.contentSize = self.imageView.bounds.size;
}



#pragma mark - Layout
- (void) restoreZoom {
    CGRect imageFrame = self.bounds;
    imageFrame.origin = CGPointZero;
    
    //reset zoomScale back to 1 so that contentSize can be modified correctly
    self.zoomScale = 1;
    
    // reset scrolling area equal to size of image
    
    //reset the image frame to the size of the image
    [self.imageView setFrame:[self frameForImageView]];
    self.contentSize = self.imageView.bounds.size;
    
    //set the zoomScale to what we actually want
    self.zoomScale = [self findZoomScale];
    
    [self centerScrollViewContents];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.activityView removeFromSuperview];
    [self setupImageViewWithImage:image];
}

- (CGRect) frameForImageView {
    CGSize imageSize = self.imageView.image.size;
    float widthRatio = self.bounds.size.width / imageSize.width;
    
    CGFloat originY, width, height;
    if (self.bounds.size.width < self.bounds.size.height) { //Portrait orientation
        if ([self.image isLandscape]) {
            width = self.bounds.size.width;
            height = imageSize.height * widthRatio;
            originY = self.bounds.origin.y + self.bounds.size.height / 2 - height / 2 - 24;
        } else {
            height = self.bounds.size.width * [self.image heightAspectRatio];
            width = self.bounds.size.width;
            originY = 0;
        }
    } else {   //Landscape orientation
        if ([self.image isLandscape]) {
            width = self.bounds.size.width;
            height = self.bounds.size.height;
            originY = self.bounds.origin.y + self.bounds.size.height / 2 - height / 2;
        } else {
            width = self.bounds.size.width;
            height = self.bounds.size.width * [self.image heightAspectRatio];
            originY = 0;
        }
    }

    
    return CGRectMake(0, originY, width, height);
}


#pragma mark - Zoom
-(float) findZoomScale {
    float widthRatio = self.bounds.size.width / self.imageView.image.size.width;
    float heightRatio = self.bounds.size.height / self.imageView.image.size.height;
    float ratio;
    if (widthRatio > heightRatio)
        ratio = widthRatio;
    else
        ratio = heightRatio;
    return MIN(ratio, 1.0f);
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"SCALE: %f", scale);
    BOOL scrollEnabled = NO;
    if (scale <= 1)
        scrollEnabled = YES;
    else
        scrollEnabled = NO;
    if ([self.imageViewDelegate respondsToSelector:@selector(shouldEnableScrolling:)]) {
        [self.imageViewDelegate shouldEnableScrolling:scrollEnabled];
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

@end
