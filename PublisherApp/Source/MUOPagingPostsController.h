//
//  MUOPagingPostsController.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 10/28/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "Post.h"

@class MUOPagingPostsController;

@protocol TopBarDelegate <NSObject>

- (void) fontSizeButtonPressed;
- (void) shareButtonPressed:(UIButton*) sender;
- (void) bookmarkButtonPressed:(UIButton*) sender;

@end


@protocol PagingControllerPresentable <NSObject>

@property (nonatomic, weak) UINavigationItem* parentNavigationItem;
@property (nonatomic, weak) MUOPagingPostsController* pagingController;
@property (nonatomic) NSInteger pageIndex;

@end


@interface MUOPagingPostsController : UIViewController

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

//Used to present single view controller using top and bottom bookmark controls
@property (nonatomic, strong) UIViewController<PagingControllerPresentable>* viewControllerToDisplay;

//Used to display view controllers in a row
@property (nonatomic, strong) Post* postToDisplay;
@property (nonatomic, strong) NSArray* posts;

//@property (nonatomic) int currentFontSize;
@property (nonatomic, weak) id<TopBarDelegate> topBarDelegate;

- (void) hideBottomView:(BOOL) hide;
- (void) animateTopView:(BOOL) shouldHide;

- (void) updateBookmarkStatus:(BOOL) selected;

@end
