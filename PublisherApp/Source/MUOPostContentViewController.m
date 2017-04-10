//
//  SPLMPostContentViewController.m
//  MakeUseOf
//
//  Created by AZAMAT on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

@import UIColor_HexString;
@import AFNetworking;
#import "MUOPostContentViewController.h"
#import "MUOPostContentViewModel.h"
#import "FontSelectorView.h"
#import "PostScrollListener.h"
#import "MUOHtmlEditor.h"
#import "ReaderSettings.h"
#import "CoreContext.h"
#import "Post.h"

#import "UIView+Toast.h"

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
   NSArray* images = @[@"post_like", @"facebook", @"messenger", @"whats-app", @"twitter"];
   NSBundle* imagesBundle = [NSBundle bundleForClass:[self class]];
   for (int i = 0; i < buttonsCount; i++) {
      UIImage* btnImage = [UIImage imageNamed:images[i] inBundle:imagesBundle compatibleWithTraitCollection:nil];
      BottomButton* btn = [self buttonWithImage:btnImage frame:CGRectMake(leftOffset + width * i, 0, width, 50)];
      btn.tag = i;
      [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
      if (i == 0) {
         self.likeBtn = btn;
      }
      
      [self addSubview:btn];
      if (i < buttonsCount - 1) {
         UIView* border = [[UIView alloc] initWithFrame:CGRectMake(width * (i + 1), 0, 1, 50)];
         border.backgroundColor = [[UIColor colorWithHexString:@"919191"] colorWithAlphaComponent:0.45];
         [self addSubview:border];
      }
   }
   
   UIView* topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 1)];
   topBorder.backgroundColor = [[UIColor colorWithHexString:@"D0D0D0"] colorWithAlphaComponent:0.5];
   [self addSubview:topBorder];
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
}

@end



#pragma mark -
#pragma mark - View controller
@interface MUOPostContentViewController ()<UIGestureRecognizerDelegate, BottomViewDelegate, FontSelectorViewDelegate, TopBarDelegate, ScrollListenerDelegate>

@property(nonatomic) MUOPostContentViewModel *viewModel;

@property (nonatomic, strong) MUOHtmlEditor* htmlEditor;

//@property (nonatomic, strong) CustomIOSAlertView* alertView;

@property (nonatomic) int currentFontSize;
@property (nonatomic) BOOL finishedLoading;
@property (nonatomic) PostScrollListener* scrollListener;

@end

@implementation MUOPostContentViewController

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
      [[AFNetworkReachabilityManager sharedManager] startMonitoring];
   }
   return self;
}

-(void)dealloc {
   NSLog(@"DEALLOC:%@", self.post.postTitle);
   self.webView.delegate = nil;
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
   
   self.scrollListener = [PostScrollListener new];
   
   
   if (!self.parentNavigationItem) {
      self.parentNavigationItem = self.navigationItem;
   }
   
   self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal - 0.00001;
   
   if (!self.finishedLoading) {
      [self fillContent];
   }
}

- (void)viewWillAppear:(BOOL)animated  {
   [super viewWillAppear:YES];
   [self applyFont];
   [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   self.scrollListener.delegate = self;
   [self.scrollListener followScrollView:self.webView.scrollView delay:60.0f];
   
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

#pragma mark - Navigation
- (void)scrolledTop {
   [self.pagingController hideBottomView:NO];
   [self.pagingController animateTopView:NO];
}

- (void)scrolledBottom {
   [self.pagingController hideBottomView:YES];
   [self.pagingController animateTopView:YES];
}


#pragma mark - Content
-(void) fillContent {
   if (self.post && _isOffline) {                                              //Displaying bookmarked post
      _post.html = [self.htmlEditor replaceLocalURLsWithNewLibraryPath:_post.html];
      [self displayHTML:_post.html];
      return;
   }
   
   self.viewModel = [MUOPostContentViewModel new];
   if (self.postID) self.viewModel.postId = self.postID;
   if (self.postSlug) self.viewModel.postSlug = self.postSlug;
   
   
   if (CONNECTION_AVAILABLE) { //If there is internet connection, display post if available, else fetch post
      _isOffline = NO;
      if (self.post) {
         [self displayHTML:_post.html];
      } else {
         [[self.viewModel loadPost] subscribeError:^(NSError *error) {
            [self.navigationController.view makeToast:@"Failed to load post" duration:1.0 position:CSToastPositionBottom];
         }];
      }
   } else {                                                       //If there is no internet connection, try to display offline post
      _isOffline = YES;
      NSString* html = self.post.html;
      [self displayHTML:html];
      [self.viewModel loadSavedPost];
   }
   
   @weakify(self);
   [[RACObserve(self.viewModel, post) ignore:nil] subscribeNext:^(Post* post){
      @strongify(self);
      self.post = post;
      if (!CONNECTION_AVAILABLE) {
         post.html = [self.htmlEditor replaceLocalURLsWithNewLibraryPath:post.html];
      }
      [self displayHTML:post.html];
   }];
}

- (void) displayHTML:(NSString *) html {
   if (_isOffline) {
      [_webView loadHTMLString:html baseURL:[NSURL URLWithString:nil]];
   } else {
      [_webView loadHTMLString:html baseURL:[NSURL URLWithString:[CoreContext sharedContext].siteURL]];
   }
}

-(void)setPost:(Post *)post {
   _post = post;
   _postID = post.ID;
   _post.html = [[MUOHtmlEditor editor] setBodyFontSize:_currentFontSize forHTML:_post.html];
   //_post.html = [[MUOHtmlEditor editor] addCSS:[MUOUserSession sharedSession].remoteCSS toHTML:post.html];
   
   [self updateBookmarkStatus];
}



#pragma mark - Bottom view 
- (void)didPressedButtonAtIndex:(int)index {
   switch (index) {
      case 0: [self likePost]; break;
      case 1: [[CoreContext sharedContext].shareHelper sharePostToFacebook:self.post fromVC:self]; break;
      case 2: [[CoreContext sharedContext].shareHelper sharePostToFBMessenger:self.post fromVC:self]; break;
      case 3: [[CoreContext sharedContext].shareHelper sharePostToWhatsapp:self.post]; break;
      case 4: [[CoreContext sharedContext].shareHelper sharePostToTwitter:self.post fromVC:self]; break;
      default:
         break;
   }
}

- (void) likePost {
   [[CoreContext sharedContext].likesManager likePost:self.post];
   [(PostContentBottomView*)self.pagingController.bottomView animateLikeButton];
}


#pragma mark - Actions
- (void)shareButtonPressed:(UIButton*) sender {
   if(self.post != nil) {
      [[CoreContext sharedContext].shareHelper sharePostWithURL:[NSURL URLWithString:self.post.url] title:self.post.postTitle presentingViewController:self fromView:sender];
   }
}

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
         [self.navigationController.view makeToast:@"Bookmark saved" duration:1.0 position:CSToastPositionBottom];
      } else {
         [self.navigationController.view makeToast:@"Bookmark removed" duration:1.0 position:CSToastPositionBottom];
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
   if (newFontSize > self.currentFontSize) {
      [self increaseFontSize];
   } else {
      [self decreaseFontSize];
   }
}

- (void) applyFont {
   if (self.currentFontSize != self.pagingController.currentFontSize && self.pagingController) {
      self.currentFontSize = self.pagingController.currentFontSize;
   }
   NSString* fontSize = [NSString stringWithFormat:@"setFontSize(%d)", self.currentFontSize];
   [self.webView stringByEvaluatingJavaScriptFromString:fontSize];
}
-(void)setCurrentFontSize:(int) currentFontSize {
   if (currentFontSize > 2) currentFontSize = 2;
   if (currentFontSize < -2) currentFontSize = -2;
   _currentFontSize = currentFontSize;
   [self.pagingController setCurrentFontSize:_currentFontSize];
   [ReaderSettings sharedSettings].preferredFontSize = _currentFontSize;
}

-(void) increaseFontSize {
   self.currentFontSize++;
   [self applyFont];
}

-(void) decreaseFontSize {
   self.currentFontSize--;
   [self applyFont];
}



#pragma mark - UIWebView
-(void)webViewDidFinishLoad:(UIWebView *)webView {
   self.finishedLoading = YES;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   if (navigationType == UIWebViewNavigationTypeLinkClicked) {
      if ([[CoreContext sharedContext].linksHandler canHandleWebviewRequest:request forViewController:self withPost:self.post]) {
         return NO;
      }
   }
   return YES;
}

- (void) refreshWebView {
   self.post.html = [[MUOHtmlEditor editor] setBodyFontSize:self.currentFontSize forHTML:self.post.html];
   [self displayHTML:self.post.html];
}


@end
