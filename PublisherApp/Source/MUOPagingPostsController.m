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

@interface MUOPagingPostsController ()<UIPageViewControllerDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property BOOL bottomViewHidden;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property BOOL topViewHidden;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;

@property BOOL shouldHideStatusBar;

@property (weak, nonatomic) id<UIGestureRecognizerDelegate> popGestureDelegate;
   @property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkButtonWidth;

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
   self.currentFontSize = [ReaderSettings sharedSettings].preferredFontSize;
   
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
      [self.navigationController setNavigationBarHidden:NO animated:YES];
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
   }
   self.shouldHideStatusBar = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   return YES;
}

- (void)setViewControllerToDisplay:(MUOPostContentViewController *)viewControllerToDisplay {
   _viewControllerToDisplay = viewControllerToDisplay;
   viewControllerToDisplay.parentNavigationItem = self.navigationItem;
   viewControllerToDisplay.pagingController = self;
}

#pragma mark - Paging controller data source
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
   NSUInteger index = ((MUOPostContentViewController*) viewController).pageIndex;
   if (index == 0 || index == NSNotFound) {
      return nil;
   }
   index--;
   return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
   NSUInteger index = ((MUOPostContentViewController*) viewController).pageIndex;
   if (index == self.posts.count - 1 || index == NSNotFound) {
      return nil;
   }
   index++;
   
   return [self viewControllerAtIndex:index];
}

- (UIViewController *) viewControllerAtIndex:(NSInteger) index {
   MUOPostContentViewController* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostContentController"];
   postVC.pageIndex = index;
   postVC.isOffline = NO;
   postVC.post = self.posts[index];
   postVC.parentNavigationItem = self.navigationItem;
   postVC.pagingController = self;
   return postVC;
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

#pragma mark - Bottom view
- (void)hideBottomView:(BOOL)hide {
   if (!self.bottomViewHidden && !hide) {
      return;
   }
   [UIView animateWithDuration:0.2 animations:^{
      self.bottomViewHidden = hide;
      self.bottomViewHeight.constant = hide ? 0 : 50;
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
