//
//  SPLMPostContentViewController.m
//  MakeUseOf
//
//  Created by AZAMAT on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

@import UIColor_HexString;
@import AFNetworking;
@import SafariServices;
@import SDWebImage;
#import "MUOPostContentViewController.h"
#import "MUOPostContentViewModel.h"
#import "FontSelectorView.h"
#import "PostScrollListener.h"
#import "MUOHtmlEditor.h"
#import "ReaderSettings.h"
#import "CoreContext.h"
#import "Post.h"
#import "ArticleBlockCell.h"
#import "NSString+MUO.h"
#import "UIView+Toast.h"
#import "UIFont+Additions.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define CONNECTION_AVAILABLE [AFNetworkReachabilityManager sharedManager].reachable

#pragma mark -
#pragma mark - Button class to use at the bottom of screen
@interface BottomButton : UIButton

@end
@implementation BottomButton
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
   BOOL inside = [super pointInside: point withEvent: event];
   if (inside && !self.isHighlighted && event.type == UIEventTypeTouches) {
      self.highlighted = YES;
   }
   return inside;
}
@end


#pragma mark -
#pragma mark - Bottom view
@protocol BottomViewDelegate <NSObject>
- (void) didPressedButtonAtIndex:(int) index;
@end

@interface PostContentBottomView : UIView
@property (nonatomic, weak) id<BottomViewDelegate> delegate;
@property (nonatomic, strong) BottomButton* likeBtn;
@end


@implementation PostContentBottomView
- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      [self layoutButtons];
   }
   return self;
}

- (void)awakeFromNib {
   [super awakeFromNib];
   [self layoutButtons];
}

- (void) layoutButtons {
   self.userInteractionEnabled = YES;
   int buttonsCount = 5;
   float width = (screen_width) / buttonsCount;
   float leftOffset = 0;
   NSArray* images = @[@"messenger", @"facebook", @"post_like", @"whats-app", @"twitter"];
   NSBundle* imagesBundle = [NSBundle bundleForClass:[self class]];
   for (int i = 0; i < buttonsCount; i++) {
      UIImage* btnImage = [UIImage imageNamed:images[i] inBundle:imagesBundle compatibleWithTraitCollection:nil];
      BottomButton* btn = [self buttonWithImage:btnImage frame:CGRectMake(leftOffset + width * i, 0, width, 48)];
      btn.tag = i;
      [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
      if (i == 0) {
         self.likeBtn = btn;
      }
      [self addSubview:btn];
   }
}

- (BottomButton *) buttonWithImage:(UIImage *) image frame:(CGRect) frame {
   BottomButton* btn = [BottomButton buttonWithType:UIButtonTypeCustom];
   [btn setFrame:frame];
   [btn setImage:image forState:UIControlStateNormal];
   return btn;
}

- (void) animateLikeButton {
   CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
   anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   anim.duration = 0.25;
   anim.repeatCount = 1;
   anim.autoreverses = YES;
   anim.removedOnCompletion = YES;
   anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
   [self.likeBtn.layer addAnimation:anim forKey:nil];
}

- (void) buttonPressed:(UIButton*) btn {
   if ([self.delegate respondsToSelector:@selector(didPressedButtonAtIndex:)]) {
      [self.delegate didPressedButtonAtIndex:(int) btn.tag];
   }
   if (btn.tag == 0) [self animateLikeButton];
}

@end

#pragma mark -
#pragma mark - View controller
@interface MUOPostContentViewController ()<UIGestureRecognizerDelegate, BottomViewDelegate, FontSelectorViewDelegate, TopBarDelegate, ScrollListenerDelegate, SFSafariViewControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet FeaturedImageView *featuredImage;
@property (nonatomic, strong) MUOHtmlEditor* htmlEditor;
@property(nonatomic) MUOPostContentViewModel *viewModel;
@property (nonatomic) PostScrollListener* scrollListener;

@property (nonatomic) int currentFontSize;
@property (nonatomic) BOOL finishedLoading;

@property (nonatomic) BOOL commentsPresented;
@end

static const int commentBtnTag = 113;

@implementation MUOPostContentViewController
//PagingControllerRepresentable
@synthesize parentNavigationItem;
@synthesize pagingController;
@synthesize pageIndex;

-(UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}


#pragma mark - Properties
-(id)initWithCoder:(NSCoder *)aDecoder {
   self = [super initWithCoder:aDecoder];
   if (self) {
      self.htmlEditor = [MUOHtmlEditor editor];
      self.currentFontSize = [ReaderSettings sharedSettings].preferredFontSize;
      self.finishedLoading = NO;
   }
   return self;
}

#pragma mark - View lifecycle
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.webView.scrollView.bounces = NO;
   self.webView.delegate = self;
   self.webView.allowsInlineMediaPlayback = YES;
   self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal - 0.00001;
   self.webView.scrollView.contentInset = UIEdgeInsetsMake(screen_width * 0.8, 0, 50, 0);
   
   self.scrollListener = [PostScrollListener new];
   
   if (!self.finishedLoading) {
      [self fillContent];
   }
}

- (void)viewWillAppear:(BOOL)animated  {
   [super viewWillAppear:YES];
   [self applyFont];
   if (![CoreContext sharedContext].bottomBarEnabled) {
      [(PostContentBottomView*)self.pagingController.bottomView removeFromSuperview];
   }
   
   [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   self.scrollListener.delegate = self;
   [self.scrollListener followScrollView:self.webView.scrollView delay:60.0f];
   self.webView.scrollView.delegate = self;
   [(PostContentBottomView*)self.pagingController.bottomView setDelegate:self];
   [self updateBookmarkStatus];
   [self.pagingController hideBottomView:NO];
   [self.pagingController animateTopView:NO];
   self.pagingController.topBarDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
   [self.scrollListener stopFollowingScrollView];
}

#pragma mark - Scrolling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   [self.scrollListener scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   [self.scrollListener scrollViewDidScroll:scrollView];
}

- (void)scrolledTop {
   [self.pagingController hideBottomView:NO];
   [self.pagingController animateTopView:NO];
}

- (void)scrolledBottom {
   [self.pagingController hideBottomView:YES];
   [self.pagingController animateTopView:YES];
}


#pragma mark - Content
-(void)setPost:(Post *)post {
   _post = post;
   _postID = post.ID;
   _post.html = [[MUOHtmlEditor editor] setBodyFontSize:_currentFontSize forHTML:post.html];
   //_post.html = [[MUOHtmlEditor editor] addCSS:[MUOUserSession sharedSession].remoteCSS toHTML:post.html];
   NSString* css = @".article__body{margin-top:0 !important;}";
   _post.html = [[MUOHtmlEditor editor] addCSS:css toHTML:_post.html];
   _post.html = [[MUOHtmlEditor editor] removeFeaturedImageBlockFromHTML:_post.html];
}

-(void) fillContent {
   if (self.post && self.isOffline) { //Displaying bookmarked post
      self.post.html = [self.htmlEditor replaceLocalURLsWithNewLibraryPath:self.post.html];
      [self displayPost];
      return;
   }
   
   self.viewModel = [MUOPostContentViewModel new];
   self.viewModel.postId = self.postID;
   self.viewModel.postSlug = self.postSlug;

   if (CONNECTION_AVAILABLE) { //If there is internet connection, display post if available, else fetch post
      [self showPost];
   } else { //If there is no internet connection, try to display offline post
      [self showOfflinePost];
   }
}

- (void) showPost {
   self.isOffline = NO;
   if (self.post) {
      [self displayPost];
   } else {
      @weakify(self);
      [[[self.viewModel loadPost] deliverOnMainThread] subscribeNext:^(Post* post) {
         @strongify(self);
         self.post = post;
         [self displayPost];
      } error:^(NSError *error) {
         @strongify(self);
         [self performSelector:@selector(showSafariVC) withObject:nil afterDelay:0.5];
      }];
   }
}

- (void) showOfflinePost {
   self.isOffline = YES;
   @weakify(self);
   [[[self.viewModel loadSavedPost] deliverOnMainThread] subscribeNext:^(Post* post) {
      @strongify(self);
      self.post = post;
      self.post.html = [self.htmlEditor replaceLocalURLsWithNewLibraryPath:self.post.html];
      [self displayPost];
   }];
}

- (void) displayPost {
   [self fillFeaturedImage];
   if (self.isOffline) {
      [_webView loadHTMLString:self.post.html baseURL:nil];
   } else {
      [_webView loadHTMLString:self.post.html baseURL:[NSURL URLWithString:[CoreContext sharedContext].siteURL]];
   }
}


#pragma mark - Bottom view 
- (void)didPressedButtonAtIndex:(int)index {
   switch (index) {
      case 0: [[CoreContext sharedContext].shareHelper sharePostToFBMessenger:self.post fromVC:self]; break;
      case 1: [[CoreContext sharedContext].shareHelper sharePostToFacebook:self.post fromVC:self]; break;
      case 2: [self likePost]; break;
      case 3: [[CoreContext sharedContext].shareHelper sharePostToWhatsapp:self.post]; break;
      case 4: [[CoreContext sharedContext].shareHelper sharePostToTwitter:self.post fromVC:self]; break;
      default:
         break;
   }
}

- (void) likePost {
   [[CoreContext sharedContext].likesManager likePost:self.post];
}


#pragma mark - Sharing
- (void)shareButtonPressed:(UIButton*) sender {
   if(self.post != nil) {
      [[CoreContext sharedContext].shareHelper sharePostWithURL:[NSURL URLWithString:self.post.url] title:self.post.postTitle presentingViewController:self fromView:sender];
   }
}


#pragma mark - Bookmarks
- (void) updateBookmarkStatus {
   if (!self.post) {
      return;
   }
   [self.pagingController updateBookmarkStatus:[[CoreContext sharedContext].savesManager bookmarkExists:self.post.ID]];
}

- (void)bookmarkButtonPressed:(UIButton *)sender {
   [self handleBookmark];
}

- (void) handleBookmark {
   @weakify(self);
   [[[CoreContext sharedContext].savesManager handleBookmark:self.post postID:self.post.ID] subscribeNext:^(NSNumber* saved) {
      @strongify(self);
      [self updateBookmarkStatus];
      if ([saved boolValue]) {
         [self.navigationController.view makeToast:[@"Bookmark saved" muoLocalized] duration:1.0 position:CSToastPositionBottom];
      } else {
         [self.navigationController.view makeToast:[@"Bookmark removed" muoLocalized] duration:1.0 position:CSToastPositionBottom];
      }
   }];
}

#pragma mark - Font size
- (void)fontSizeButtonPressed {
   self.navigationController.interactivePopGestureRecognizer.enabled = NO;
   FontSelectorView* view = [[FontSelectorView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
   view.delegate = self;
   view.fontSize = self.currentFontSize;
   [view presentView:YES fromView:self.navigationController.view];
}

- (void)fontSelectorViewDidDismiss {
   self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)fontSizeValueDidChanged:(NSInteger)newFontSize {
   [ReaderSettings sharedSettings].preferredFontSize = newFontSize;
   [self applyFont];
}

- (void) applyFont {
   self.currentFontSize = [ReaderSettings sharedSettings].preferredFontSize;
   NSString* fontSize = [NSString stringWithFormat:@"setFontSize(%d)", self.currentFontSize];
   [self.webView stringByEvaluatingJavaScriptFromString:fontSize];
}


#pragma mark - Comments
- (void)commentButtonPressed {
   if ([[CoreContext sharedContext].groupOpener respondsToSelector:@selector(openGroupForPost:channelID:title:avatar:)]) {
      [[CoreContext sharedContext].groupOpener openGroupForPost:self.post.ID channelID:self.post.channelId title:self.post.postTitle avatar:self.post.featuredImage.middle];
   }
}

#pragma mark - Featured image
- (void) fillFeaturedImage {
   [self.featuredImage fillWithPost:self.post];
   UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(featuredImageTap:)];
   tapGesture.delegate = self;
   tapGesture.numberOfTapsRequired = 1;
   [self.webView addGestureRecognizer:tapGesture];
}

- (void) featuredImageTap:(UITapGestureRecognizer*) recognizer {
   if (self.webView.scrollView.contentOffset.y < 0) {
      CGPoint tapLocation = [recognizer locationInView:self.webView];
      if (CGRectContainsPoint(self.featuredImage.frame, tapLocation)) {
         [[CoreContext sharedContext].linksHandler handleURL:self.post.featuredImage.featured fromViewController:self withPost:self.post];
      }
   }
}


#pragma mark - Safari
- (void) showSafariVC {
   SFSafariViewController* safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.postSlug]];
   safari.delegate = self;
   [self.parentViewController presentViewController:safari animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
   NSInteger selfIndex = [self.navigationController.viewControllers indexOfObject:self.pagingController];
   if (selfIndex <= 1) {
      [self.navigationController setNavigationBarHidden:NO animated:YES];
      [self setNeedsStatusBarAppearanceUpdate];
   }
   [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:selfIndex - 1] animated:YES];
}

#pragma mark - UIWebView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   return true;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
   self.finishedLoading = YES;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   if (navigationType == UIWebViewNavigationTypeLinkClicked) {
      [[CoreContext sharedContext].linksHandler handleURL:request.URL fromViewController:self withPost:self.post];
      return NO;
   }
   return YES;
}


#pragma mark - Dealloc
-(void)dealloc {
   NSLog(@"DEALLOC:%@", self.post.postTitle);
   self.webView.delegate = nil;
}

@end
