//
//  HorisontalScrollListener.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/24/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol ScrollListenerDelegate <NSObject>

- (void) scrolledTop;
- (void) scrolledBottom;

@end

@interface PostScrollListener : NSObject

- (void) followScrollView:(UIScrollView*) scrollView delay:(double)delay;
- (void) stopFollowingScrollView;

@property (nonatomic, weak) id<ScrollListenerDelegate> delegate;

@end
