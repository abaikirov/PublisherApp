//
//  MUOPagingPostsController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 10/28/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOPostContentViewController.h"
#import "MUOPagingPostsController.h"
#import "ReaderSettings.h"
#import "CoreContext.h"
#import "BlocksContentController.h"
#import "CoreContext.h"

@interface MUOPagingPostsController ()<UIPageViewControllerDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) id<UIGestureRecognizerDelegate> popGestureDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkButtonWidth;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@property BOOL bottomViewHidden;
@property BOOL topViewHidden;
@property BOOL shouldHideStatusBar;

@end

@implementation MUOPagingPostsController

#pragma mark - View lifecycle
-(UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
   return self.shouldHideStatusBar;
}

-(BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"";
   self.bottomViewHidden = NO;
   self.topViewHidden = NO;
   self.pageViewController = self.childViewControllers[0];
   //self.currentFontSize = [ReaderSettings sharedSettings].preferredFontSize;
   
   if (self.viewControllerToDisplay) {
      [self.pageViewController setViewControllers:@[self.viewControllerToDisplay] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
   } else {
      self.pageViewController.dataSource = self;
      int currentPage = (int)[self.posts indexOfObject:self.postToDisplay];
      [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
   }
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   if (![CoreContext sharedContext].bookmarksEnabled) {
      self.bookmarkButtonWidth.constant = 0;
   }
   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
   [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   self.shouldHideStatusBar = YES;
   
   [UIView animateWithDuration:0.3 animations:^{
      [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
   }];
   
   self.popGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
   self.navigationController.interactivePopGestureRecognizer.delegate = self;
   //self.bottomViewHeight.constant = [CoreContext sharedContext].commentsEnabled ? 80 : 40;
}

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
   if ([self isMovingFromParentViewController]) {
      NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
      self.navigationController.interactivePopGestureRecognizer.delegate = self.popGestureDelegate;
      if (numberOfViewControllers > 1) {
         UIViewController* backViewController = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 1];
         if ([backViewController isKindOfClass:[MUOPagingPostsController class]]) {
            return;
         }
      }
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.navigationController setNavigationBarHidden:NO animated:YES];
   }
   self.shouldHideStatusBar = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
   shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   return YES;
}

- (void)setViewControllerToDisplay:(UIViewController<PagingControllerPresentable> *)viewControllerToDisplay {
   _viewControllerToDisplay = viewControllerToDisplay;
   viewControllerToDisplay.parentNavigationItem = self.navigationItem;
   viewControllerToDisplay.pagingController = self;
}

#pragma mark - Paging controller data source
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController<PagingControllerPresentable> *)viewController {
   NSUInteger index = viewController.pageIndex;
   if (index == 0 || index == NSNotFound) {
      return nil;
   }
   index--;
   return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController<PagingControllerPresentable> *)viewController {
   NSUInteger index = viewController.pageIndex;
   if (index == self.posts.count - 1 || index == NSNotFound) {
      return nil;
   }
   index++;
   
   return [self viewControllerAtIndex:index];
}

#pragma mark - Webview posts data source
- (UIViewController *) viewControllerAtIndex:(NSInteger) index {
   if ([CoreContext sharedContext].useBlocks) {
      return [self blocksContentControllerAtIndex:index];
   } else {
      return [self postContentControllerAtIndex:index];
   }
}

#pragma mark - Web view controller
- (UIViewController *) postContentControllerAtIndex:(NSInteger) index {
   MUOPostContentViewController* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostContentController"];
   postVC.isOffline = NO;
   postVC.post = self.posts[index];
   return [self applyPagination:postVC page:index];
}

- (UIViewController*) blocksContentControllerAtIndex:(NSInteger) index {
   BlocksContentController* blocksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BlocksVC"];
   blocksVC.post = self.posts[index];
   return [self applyPagination:blocksVC page:index];
}

- (UIViewController*) applyPagination:(UIViewController<PagingControllerPresentable> *)vc page:(NSInteger) page {
   vc.pageIndex = page;
   vc.parentNavigationItem = self.navigationItem;
   vc.pagingController = self;
   return vc;
}

#pragma mark - Top view
- (IBAction)backButtonPressed:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)fontSizeButtonPressed:(id)sender {
   [self.topBarDelegate fontSizeButtonPressed];
}

- (IBAction)shareButtonPressed:(id)sender {
   [self.topBarDelegate shareButtonPressed:sender];
}

- (IBAction)bookmarkButtonPressed:(id)sender {
   [self.topBarDelegate bookmarkButtonPressed:sender];
}
- (IBAction)commentButtonPressed:(id)sender {
   [self.topBarDelegate commentButtonPressed];
}

#pragma mark - Bottom view
- (void)hideBottomView:(BOOL)hide {
   if (!self.bottomViewHidden && !hide) {
      return;
   }
   [UIView animateWithDuration:0.2 animations:^{
      self.bottomViewHidden = hide;
      self.bottomViewHeight.constant = hide ? 0 : 48;
      [self.view layoutIfNeeded];
   }];
}


#pragma mark - Top view
- (void)animateTopView:(BOOL)shouldHide {
   if (!self.topViewHidden && !shouldHide) {
      return;
   }
   [UIView animateWithDuration:0.2 animations:^{
      self.topViewHidden = shouldHide;
      self.topViewHeight.constant = shouldHide ? 0 : 60;
      [self.view layoutIfNeeded];
   }];
}

- (void)updateBookmarkStatus:(BOOL)selected {
   [self.bookmarkButton setSelected:selected];
}

- (void)dealloc {
   NSLog(@"PAGE VIEW CONTROLLER DEALLOC");
}

@end
