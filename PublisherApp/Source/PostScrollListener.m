//
//  HorisontalScrollListener.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/24/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "PostScrollListener.h"
@import UIKit;

@interface PostScrollListener() <UIScrollViewDelegate>

@property (nonatomic) CGFloat delay;
@property (nonatomic) CGFloat initialOffset;
@property (nonatomic) BOOL shouldHandleScroll;
@property (nonatomic, strong) UIScrollView* scrollView;

@end

@implementation PostScrollListener

- (void)followScrollView:(UIScrollView *)scrollView delay:(double)delay {
   self.delay = delay;
   self.scrollView = scrollView;
   scrollView.delegate = self;
}

- (void)stopFollowingScrollView {
   self.scrollView.delegate = nil;
}

#pragma mark - Scroll view
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   self.shouldHandleScroll = YES;
   self.initialOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   CGFloat yOffset = scrollView.contentOffset.y;
   if (yOffset == 0.0) {
      [self.delegate scrolledTop];
   }
   
   if (_shouldHandleScroll) {
      if (yOffset > self.initialOffset) {
         if (yOffset - _initialOffset > self.delay) {
            [self.delegate scrolledBottom];
            self.shouldHandleScroll = NO;
         }
      } else {
         [self.delegate scrolledTop];
         self.shouldHandleScroll = NO;
      }
   }
}

@end
