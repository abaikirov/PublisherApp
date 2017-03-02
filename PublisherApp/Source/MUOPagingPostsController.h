//
//  MUOPagingPostsController.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 10/28/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "Post.h"

@protocol TopBarDelegate <NSObject>

- (void) fontSizeButtonPressed;
- (void) shareButtonPressed:(UIButton*) sender;
- (void) bookmarkButtonPressed:(UIButton*) sender;

@end

@class MUOPostContentViewController;
@interface MUOPagingPostsController : UIViewController

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, strong) MUOPostContentViewController* viewControllerToDisplay;
@property (nonatomic, strong) Post* postToDisplay;
@property (nonatomic, strong) NSArray* posts;
@property (nonatomic) int currentFontSize;
@property (nonatomic, weak) id<TopBarDelegate> topBarDelegate;

- (void) hideBottomView:(BOOL) hide;
- (void) animateTopView:(BOOL) shouldHide;

- (void) updateBookmarkStatus:(BOOL) selected;

@end
