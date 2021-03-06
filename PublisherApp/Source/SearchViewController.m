//
//  SearchViewController.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 4/3/17.
//
//

#import "SearchViewController.h"
#import "CategoriesRequestsManager.h"
#import "CategoriesRequestsManager.h"
#import "Post.h"
#import "CategoryPostsViewController.h"
#import "NSString+MUO.h"

@import ReactiveCocoa;
@import UIColor_HexString;

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) CategoriesRequestsManager* requestsManager;

@end

@implementation SearchViewController

#pragma mark - View lifecycle
-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[@"Cancel" muoLocalized]
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
   self.requestsManager = [CategoriesRequestsManager new];
   self.automaticallyAdjustsScrollViewInsets = YES;
   [self initTableView];
   [self loadCategories];
   self.title = @"";
}

- (void) initTableView {
   self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
   [self.view addSubview:self.tableView];
   
   [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CategoryCell"];
   self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
   self.tableView.dataSource = self;
   self.tableView.delegate = self;
   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) cancelButtonPressed {
   UIView* selfCopy = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
   [[UIApplication sharedApplication].keyWindow addSubview:selfCopy];
   [self dismissViewControllerAnimated:NO completion:nil];
   [UIView animateWithDuration:0.23 animations:^{
      selfCopy.frame = CGRectMake(-screen_width, 0, screen_width, screen_height);
   } completion:^(BOOL finished) {
      [selfCopy removeFromSuperview];
   }];
}

#pragma mark - Table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.categories.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   cell.textLabel.textColor = [UIColor colorWithHexString:@"432D2D"];
   PostCategory* category = self.categories[indexPath.row];
   cell.textLabel.text = category.title;
   return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   PostCategory* selectedCategory = self.categories[indexPath.row];
   CategoryPostsViewController* vc = [[UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"CategoryPostsVC"];
   vc.filteredCategory = selectedCategory;
   [self.navigationController pushViewController:vc animated:YES];
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   return [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Server interaction
- (void) loadCategories {
   @weakify(self);
   [[self.requestsManager fetchCategories] subscribeNext:^(NSArray* categories) {
      @strongify(self);
      self.categories = categories;
      [self.tableView reloadData];
   } error:^(NSError *error) {
      
   }];
}

- (void)dealloc {
   
}

@end
