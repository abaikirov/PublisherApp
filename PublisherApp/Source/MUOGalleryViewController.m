//
//  MUOGalleryViewController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/7/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOGalleryViewController.h"
#import "MUOScrollingImageView.h"
@import SDWebImage;

@interface MUOGalleryViewController()<UIScrollViewDelegate, ScrollingImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;

@property (nonatomic, strong) NSArray* imageURLs;

@property (nonatomic, strong) NSMutableArray* scrollingImageViews;

@property (nonatomic) NSInteger page;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, strong) UIImageView* zoomingImageView;

@property (nonatomic) CGRect initialPanViewFrame;
@property (nonatomic) CGPoint initialPanCenter;

@property (nonatomic, strong) SDWebImageDownloader* downloader;

@end


const int kTopOffset = 32;
const int kBottomOffset = 20;
const int kDismissOffset = 120;

@implementation MUOGalleryViewController


#pragma mark - View lifecycle
-(UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad {
   [super viewDidLoad];
   
   self.downloader = [[SDWebImageDownloader alloc] init];
   
   UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
   [self.view addGestureRecognizer:recognizer];
   
   CGRect frame = self.view.bounds;
   self.scrollView.pagingEnabled = YES;
   self.scrollView.frame = frame;
   self.scrollView.delegate = self;
   self.scrollView.minimumZoomScale = 1.0f;
   self.scrollView.maximumZoomScale = 2.0f;
   
   self.scrollingImageViews = [NSMutableArray new];
   for (int i = 0; i < _imageURLs.count; i++) {
      MUOScrollingImageView* imgView = [[MUOScrollingImageView alloc] initWithFrame:CGRectMake(frame.size.width * i, kTopOffset, frame.size.width, frame.size.height - kTopOffset - kBottomOffset)];
      imgView.imageViewDelegate = self;
      [self.scrollingImageViews addObject:imgView];
      [self.scrollView addSubview:imgView];
   }
   
   [_scrollView setContentSize:CGSizeMake(frame.size.width * _imageURLs.count, frame.size.height - kTopOffset - kBottomOffset)];
   [_scrollView setContentOffset:CGPointMake(frame.size.width * _page, 0) animated:YES];
   [self updateWithCounter:(int)_page];
   
   [self displayRemoteImages];
   
   [self.view bringSubviewToFront:_closeButton];
   [self.view bringSubviewToFront:_shareButton];
}


#pragma mark - Rotation
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
   [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
   int currentPage = _scrollView.contentOffset.x / self.view.frame.size.width;
   [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      [_scrollView setContentSize:CGSizeMake(size.width * _imageURLs.count, size.height - kTopOffset - kBottomOffset)];
      [_scrollView setContentOffset:CGPointMake(size.width * currentPage, 0) animated:NO];
      for (int i = 0; i < _scrollingImageViews.count; i++) {
         CGRect newFrame = CGRectMake(size.width * i, kTopOffset, size.width, size.height - kTopOffset - kBottomOffset);
         [_scrollingImageViews[i] setFrame:newFrame];
         [_scrollingImageViews[i] restoreZoom];
      }
   } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      [self.view bringSubviewToFront:_closeButton];
      [self.view bringSubviewToFront:_counterLabel];
   }];
}


#pragma mark - Gestures
- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
   UIView* currentView = _scrollingImageViews[_page];
   CGPoint location = [recognizer locationInView:self.view];
   if (recognizer.state == UIGestureRecognizerStateBegan) {
      self.initialPanViewFrame = currentView.frame;
      self.initialPanCenter = location;
   }
   CGFloat diff = self.initialPanCenter.y - location.y;
   CGPoint modifiedLocation = CGPointMake(currentView.center.x, CGRectGetMidY(self.initialPanViewFrame) - diff);
   if (recognizer.state == UIGestureRecognizerStateEnded) {  //Restore initial image position
      [self restoreInitialPositionForView:currentView duration: (diff / kDismissOffset) * .5];
      return;
   } else {
      currentView.center = modifiedLocation;
   }
   
   float alpha = 1.0 - (fabs(diff) / kDismissOffset);
   currentView.alpha = alpha;
   if (fabs(diff) > kDismissOffset) {
      self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      [self dismissViewControllerAnimated:YES completion:nil];
   }
}

- (void) restoreInitialPositionForView:(UIView *) currentView duration:(float) duration{
   [UIView animateWithDuration:duration animations:^{
      currentView.alpha = 1.0f;
      currentView.frame = self.initialPanViewFrame;
   }];
}

#pragma mark - Displaying images
- (void)fillWithImages:(NSArray *)imageURLs currentImage:(NSString *)imageURL {
   _imageURLs = imageURLs;
   
   _page = [_imageURLs indexOfObject:imageURL];
}

-(void) displayRemoteImages {
   for (int i = 0; i < _imageURLs.count; i++) {
      [self.downloader downloadImageWithURL:[NSURL URLWithString:_imageURLs[i]]
                                    options:SDWebImageDownloaderUseNSURLCache
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      
                                   } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.scrollingImageViews[i] setImage:image];
                                      });
                                   }];
   }
}

-(void) updateWithCounter:(int) counter {
   _page = counter;
   [self.counterLabel setText:[NSString stringWithFormat:@"%d of %lu", counter + 1, (unsigned long)_imageURLs.count]];
}

#pragma mark - Scroll view
-(void)shouldEnableScrolling:(BOOL)enabled {
   self.scrollView.scrollEnabled = enabled;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
   CGPoint offset = scrollView.contentOffset;
   int index = offset.x / _scrollView.frame.size.width;
   [self updateWithCounter:index];
}

#pragma mark - Actions
- (IBAction)closeBtnPressed:(id)sender {
   [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)shareButtonPressed:(id)sender {
   UIImage* imageToShare = [(MUOScrollingImageView *)self.scrollingImageViews[_page] image];
   if (!imageToShare) {
      return;
   }
   UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[imageToShare] applicationActivities:nil];
   if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
      activityVC.popoverPresentationController.sourceView = self.view;
   }
   [self presentViewController:activityVC animated:YES completion:nil];
}


- (void)dealloc {
   NSLog(@"GALLERY DEALLOC");
}

@end
