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

@interface BlocksContentController ()<UITableViewDataSource, UITableViewDelegate, LinkTapDelegate, TopBarDelegate, FontSelectorViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;
@property (nonatomic, strong) BlocksDataProvider* blocksProvider;
@property (nonatomic) int currentFontSize;

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
   self.blocksTableView.delegate = self;
   self.blocksTableView.estimatedRowHeight = 200.0;
   self.blocksTableView.rowHeight = UITableViewAutomaticDimension;
   self.blocksTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
   [self setupDataProvider];
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   self.pagingController.topBarDelegate = self;
}

#pragma mark - Blocks Provider
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
   return [self.blocksProvider heightForBlock:blockToDisplay];
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
