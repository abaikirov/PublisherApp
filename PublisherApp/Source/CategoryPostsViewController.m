//
//  CategoryPostsViewController.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 4/4/17.
//
//

#import "CategoryPostsViewController.h"
#import "Post.h"
#import "PostTableViewCell.h"
#import "CategoryPostsViewModel.h"
#import "CoreContext.h"

@interface CategoryPostsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<Post*>* posts;
@property (nonatomic, strong) CategoryPostsViewModel* viewModel;
@property (nonatomic) BOOL loadingInProgress;

@end

@implementation CategoryPostsViewController

#pragma mark - View lifecycle
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.posts = [NSMutableArray new];
   self.viewModel = [CategoryPostsViewModel new];
   [self setupTableView];
   [self update];
   
   self.navigationItem.title = self.filteredCategory.title;
}

#pragma mark - Table view
- (void) setupTableView {
   self.tableView.dataSource = self;
   self.tableView.delegate = self;
   [self.tableView registerNib:[UINib nibWithNibName:@"PostTableViewCell" bundle:[PostTableViewCell bundle]] forCellReuseIdentifier:[PostTableViewCell cellID]];
   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return [PostTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   Post* post = self.posts[indexPath.row];
   PostTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[PostTableViewCell cellID]];
   [cell fillWithPost:post];
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   Post* selectedPost = self.posts[indexPath.row];
   [[CoreContext sharedContext].navigationRouter showPost:selectedPost fromNavigationController:self.navigationController isOffline:NO];
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == self.posts.count - 1 && self.posts.count != 0 && !self.loadingInProgress) {
      [self loadMore];
   }
}
   
#pragma mark - Server interaction
- (void) update {
   [self.viewModel appendFilter:self.filteredCategory];
   [self.viewModel resetPage];
   [self fetchPosts];
}

- (void) fetchPosts {
   self.loadingInProgress = YES;
   
   @weakify(self);
   [[self.viewModel fetchPosts] subscribeNext:^(NSArray* newPosts) {
      @strongify(self);
      self.loadingInProgress = NO;
      [self.posts addObjectsFromArray:newPosts];
      [self.tableView reloadData];
   } error:^(NSError *error) {
      
   }];
}

- (void) loadMore {
   NSNumber* lastPostID = self.posts.lastObject.ID;
   self.viewModel.lastPostID = lastPostID;
   self.viewModel.lastPostDate = self.posts.lastObject.postDate;
   [self.viewModel setNextPage];
   [self fetchPosts];
}

@end
