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

@interface BlocksContentController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;
@property (nonatomic, strong) BlocksDataProvider* blocksProvider;

@end

@implementation BlocksContentController
@synthesize parentNavigationItem;
@synthesize pagingController;
@synthesize pageIndex;

#pragma mark - View lifecycle
- (void)viewDidLoad {
   [super viewDidLoad];
   self.blocksTableView.dataSource = self;
   self.blocksTableView.delegate = self;
   self.blocksTableView.estimatedRowHeight = 200.0;
   self.blocksTableView.rowHeight = UITableViewAutomaticDimension;
   self.blocksTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
   [self setupDataProvider];
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
   return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == 0) {
      return UITableViewAutomaticDimension;
   }
   ArticleBlock* blockToDisplay = [self.blocksProvider blockForIndexPath:indexPath];
   return [self.blocksProvider heightForBlock:blockToDisplay];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

@end
