//
//  BlocksContentController.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import "BlocksContentController.h"
#import "ArticleBlockCell.h"
#import "BlocksDataProvider.h"
#import "CoreContext.h"
#import "FontSelectorView.h"
#import "ReaderSettings.h"
#import "PostScrollListener.h"

@interface BlocksContentController ()<UITableViewDataSource, UITableViewDelegate, LinkTapDelegate, TopBarDelegate, FontSelectorViewDelegate, ScrollListenerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;
@property (nonatomic, strong) BlocksDataProvider* blocksProvider;
@property (nonatomic) PostScrollListener* scrollListener;
@property (nonatomic) int currentFontSize;
@property (nonatomic) NSMutableDictionary* webContentHeights;

@end

@implementation BlocksContentController
@synthesize parentNavigationItem;
@synthesize pagingController;
@synthesize pageIndex;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   self = [super initWithCoder:aDecoder];
   if (self) {
      self.currentFontSize = [ReaderSettings sharedSettings].preferredFontSize;
   }
   return self;
}


- (void)setPost:(Post *)post {
   _post = post;
   [post prerenderBlocksWithIndexes:nil updateBlock:nil];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
   [super viewDidLoad];
   self.blocksTableView.dataSource = self;
   self.blocksTableView.estimatedRowHeight = 200.0;
   self.blocksTableView.rowHeight = UITableViewAutomaticDimension;
   self.blocksTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
   [self setupYoutubeCells];
   [self setupWebCells];
   self.scrollListener = [PostScrollListener new];
   [self setupDataProvider];
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   if (self.currentFontSize != [ReaderSettings sharedSettings].preferredFontSize) {
      [self applyFont];
   }
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   self.pagingController.topBarDelegate = self;
   self.scrollListener.delegate = self;
   [self.scrollListener followScrollView:self.blocksTableView delay:60.0f];
   self.blocksTableView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
   [self.scrollListener stopFollowingScrollView];
}

#pragma mark - Blocks Provider
- (void) setupYoutubeCells {
   NSBundle* bundle = [NSBundle bundleForClass:[self class]];
   UINib* nib = [UINib nibWithNibName:@"YoutubeBlockCell" bundle:bundle];
   NSArray* youtubeIDs = [self.post youtubeBlocksIDs];
   for (NSString* ID in youtubeIDs) {
      [self.blocksTableView registerNib:nib forCellReuseIdentifier:ID];
   }
}

- (void) setupWebCells {
   self.webContentHeights = [NSMutableDictionary new];
   NSBundle* bundle = [NSBundle bundleForClass:[self class]];
   UINib* nib = [UINib nibWithNibName:@"WebBlockCell" bundle:bundle];
   for (ArticleBlock* block in self.post.blocks) {
      if ([block displaysWebContent]) {
         NSString* reuseID = [NSString stringWithFormat:@"%@_%d", block.type, [self.post.blocks indexOfObject:block]];
         [self.blocksTableView registerNib:nib forCellReuseIdentifier:reuseID];
      }
   }
}

- (void) setupDataProvider {
   self.blocksProvider = [[BlocksDataProvider alloc] initWithTableView:self.blocksTableView blocks:self.post.blocks];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.blocksProvider numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == 0) {
      ArticleHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:[ArticleHeaderCell reuseIdentifier]];
      [cell fillWithPost:self.post];
      return cell;
   }
   ArticleBlock* blockToDisplay = [self.blocksProvider blockForIndexPath:indexPath];
   Class<ArticleBlockCell> cellClass = [self.blocksProvider cellClassForBlock:blockToDisplay];
   UITableViewCell<ArticleBlockCell>* cell = [tableView dequeueReusableCellWithIdentifier:[cellClass reuseIdentifier]];
   if ([blockToDisplay.type isEqualToString:kYoutubeBlock]) { 
      cell = [tableView dequeueReusableCellWithIdentifier:[blockToDisplay youtubeID]];
   }
   if ([blockToDisplay displaysWebContent]) {
      NSString* reuseID = [NSString stringWithFormat:@"%@_%d", blockToDisplay.type,[self.post.blocks indexOfObject:blockToDisplay]];
      cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
      [(WebBlockCell*)cell webView].tag = indexPath.row;
      [(WebBlockCell*)cell webView].delegate = self;
   }
   [cell fillWithBlock:blockToDisplay];
   
   if ([blockToDisplay canDisplayLink]) {
      [(TextDisplayingCell*)cell setLinkDelegate:self];
   }
   
   return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == 0) {
      return UITableViewAutomaticDimension;
   }
   ArticleBlock* blockToDisplay = [self.blocksProvider blockForIndexPath:indexPath];
   if ([blockToDisplay displaysWebContent]) {
      if(self.webContentHeights[@(indexPath.row)] != nil) {
         return [self.webContentHeights[@(indexPath.row)] floatValue];
      }
   }
   return [self.blocksProvider heightForBlock:blockToDisplay];
}

- (void)webViewDidFinishLoad:(BlockWebView *)webView {
   webView.isLoaded = YES;
   webView.numberOfLoads++;
   NSIndexPath* indexPath = [NSIndexPath indexPathForRow:webView.tag inSection:0];
   ArticleBlock* blockToDisplay = [self.blocksProvider blockForIndexPath:indexPath];
   NSInteger numberOfLoadsToUpdate = 1;
   if ([blockToDisplay.type isEqualToString:kTwitterBlock]) numberOfLoadsToUpdate = 3;
   if (webView.numberOfLoads == numberOfLoadsToUpdate) {
      self.webContentHeights[@(webView.tag)] = @(webView.scrollView.contentSize.height);
      if ([[self.blocksTableView indexPathsForVisibleRows] containsObject:indexPath]) {
         [self.blocksTableView setContentOffset:self.blocksTableView.contentOffset animated:NO];
         [self.blocksTableView beginUpdates];
         [self.blocksTableView endUpdates];
      }
   }
   
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == 0) {
      NSArray* images = [self.post imagesFromBlocks];
      [[CoreContext sharedContext].navigationRouter showLocalGallery:NO withImages:images
                                                     presentingImage:[self.post.featuredImage.featured absoluteString] fromVC:self];
      return;
   }
   ArticleBlock* blockToDisplay = [self.blocksProvider blockForIndexPath:indexPath];
   if ([blockToDisplay.type isEqualToString:kImageBlock]) {
      NSString* imageToDisplay = [blockToDisplay image];
      NSArray* images = [self.post imagesFromBlocks];
      [[CoreContext sharedContext].navigationRouter showLocalGallery:NO withImages:images presentingImage:imageToDisplay fromVC:self];
   }
}


#pragma mark - Scroll view
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   [self.scrollListener scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   [self.scrollListener scrollViewDidScroll:scrollView];
}

#pragma mark - Scrolling
- (void)scrolledTop {
   [self.pagingController hideBottomView:NO];
   [self.pagingController animateTopView:NO];
}

- (void)scrolledBottom {
   [self.pagingController hideBottomView:YES];
   [self.pagingController animateTopView:YES];
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
   NSArray* visibleBlocksIndexes = [[self.blocksTableView indexPathsForVisibleRows].rac_sequence map:^id(NSIndexPath* indexPath) {
      if (indexPath.row == 0) return nil;
      return @(indexPath.row - 1);
   }].array;
   [self.post prerenderBlocksWithIndexes:visibleBlocksIndexes updateBlock:^{
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.blocksTableView reloadData];
      });
   }];
}

#pragma mark - Bookmarks
- (void)bookmarkButtonPressed:(UIButton *)sender {
   
}


#pragma mark - Sharing
- (void)shareButtonPressed:(UIButton *)sender {
   if(self.post != nil) {
      [[CoreContext sharedContext].shareHelper sharePostWithURL:[NSURL URLWithString:self.post.url] title:self.post.postTitle presentingViewController:self fromView:sender];
   }
}

#pragma mark - Hanling links
- (void)linkTapped:(NSURL *)url {
   [[CoreContext sharedContext].linksHandler handleURL:url fromViewController:self withPost:self.post];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)dealloc {
   NSLog(@"%@ dealloc", self.post.postTitle);
}

@end
