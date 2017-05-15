//
//  BlocksContentController.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import "BlocksContentController.h"
#import "ArticleBlockCell.h"

@interface BlocksContentController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *blocksTableView;

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
}

#pragma mark - Data source 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   ArticleHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:[ArticleHeaderCell reuseIdentifier]];
   [cell fillWithPost:self.post];
   return cell;
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

@end
