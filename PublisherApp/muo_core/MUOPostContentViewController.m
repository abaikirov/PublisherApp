//
//  SPLMPostContentViewController.m
//  MakeUseOf
//
//  Created by AZAMAT on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "MUOPostContentViewController.h"
#import "Post.h"

#import "UIColor+HexString.h"
#import "MUOHtmlEditor.h"
#import "MUOGalleryViewController.h"
#import "UserSettings.h"
#import "FontSelectorView.h"
#import "PublisherApp.h"

#define BASE_URL @"http://makeuseof.com"

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
   for (int i = 0; i < buttonsCount; i++) {
      BottomButton* btn = [self buttonWithImage:[UIImage imageNamed:images[i]] frame:CGRectMake(leftOffset + width * i, 0, width, 50)];
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
      [self.delegate didPressedButtonAtIndex:btn.tag];
   }
}

@end



#pragma mark -
#pragma mark - View controller
@interface MUOPostContentViewController ()<UIGestureRecognizerDelegate, BottomViewDelegate, TopBarDelegate, FontSelectorViewDelegate>


@property (nonatomic) int currentFontSize;
@property (nonatomic) BOOL finishedLoading;

@property (nonatomic, strong) UIBarButtonItem* fontItem;

@end

@implementation MUOPostContentViewController

-(UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}


#pragma mark - Properties
-(id)initWithCoder:(NSCoder *)aDecoder {
   self = [super initWithCoder:aDecoder];
   if (self) {
      self.finishedLoading = NO;
      self.currentFontSize = [UserSettings sharedSettings].preferredFontSize;
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
   
   if (!self.parentNavigationItem) {
      self.parentNavigationItem = self.navigationItem;
   }
   
   self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal - 0.00001;
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
   
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
   
   [(PostContentBottomView*)self.pagingController.bottomView setDelegate:self];
   [self.pagingController hideBottomView:NO];
   [self.pagingController animateTopView:NO];
   self.pagingController.topBarDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
}



#pragma mark - Content
-(void) fillContent {
   [self displayHTML:_post.html];
}

- (void) displayHTML:(NSString *) html {
   if (_isOffline) {
      [_webView loadHTMLString:html baseURL:[NSURL URLWithString:nil]];
   } else {
      [_webView loadHTMLString:html baseURL:[NSURL URLWithString:BASE_URL]];
   }
}

-(void)setPost:(Post *)post {
   _post = post;
   _post.html = [[MUOHtmlEditor editor] setBodyFontSize:_currentFontSize forHTML:_post.html];
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
   [UserSettings sharedSettings].preferredFontSize = _currentFontSize;
}

-(void) increaseFontSize {
   self.currentFontSize++;
   [self applyFont];
}

-(void) decreaseFontSize {
   self.currentFontSize--;
   [self applyFont];
}



#pragma mark - Bottom view 
- (void)didPressedButtonAtIndex:(int)index {
   switch (index) {
      case 0: //Like
         [self likePost];
      break;
         
      case 3: {
         NSString* shareText = [NSString stringWithFormat:@"whatsapp://send?text=%@\n\nvia MakeUseOf.com/app", self.post.url];
         shareText = [shareText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         NSURL *whatsappURL = [NSURL URLWithString:shareText];
         if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
         }
      }
      break;
      
      case 4:
         [self shareToTwitter];
         break;
         
      case 1:
         [self shareToFacebook];
      break;
      case 2:
         [self shareToMessenger];
      break;
         
      default:
         break;
   }
}

- (void) shareToTwitter {
   
}

- (void) shareToFacebook {
   
}

- (void) shareToMessenger {
   
}

- (void) likePost {
   
}



#pragma mark - Actions
- (void)shareButtonPressed:(UIButton*) sender {
   if(self.post != nil) {
      //[MUOShareHelper sharePostWithURL:[NSURL URLWithString:self.post.url] title:self.post.postTitle presentingViewController:self fromView:sender];
   }
}





#pragma mark - UIWebView
-(void)webViewDidFinishLoad:(UIWebView *)webView {
   self.finishedLoading = YES;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   if (navigationType == UIWebViewNavigationTypeLinkClicked) {
      NSString* urlString = [request.URL absoluteString];
      if ([urlString hasPrefix:@"http://cdn.makeuseof.com"]) {
         MUOGalleryViewController* galleryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GalleryVC"];
         NSArray* images = [[MUOHtmlEditor editor] getImagesFromHTML:self.post.html];
         [galleryVC fillWithImages:images currentImage:urlString];
         
         //It's better to show gallery from page view controller. It is more stable in such way
         [self.parentViewController presentViewController:galleryVC animated:YES completion:^{
            
         }];
      } else {
         [[UIApplication sharedApplication] openURL:request.URL];
      }
      return NO;
   }
   return YES;
}



@end
