//
//  ViewController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/11/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
@import DateTools;
@import UIColor_HexString;

#import "MUOPostsViewController.h"
#import "PostsViewModel.h"
#import "Post.h"
#import "SDWebImagePrefetcher+MUO.h"
#import "MUOPagingPostsController.h"
#import "ReaderSmallCell.h"
#import "ReaderLargeCell.h"
#import "PublisherApp.h"


#define CELL_HEIGHT 95
#define LAST_CELL_HEIGHT 45
#define CATEGORIES_SEGUE_ID @"segueCategories"




#pragma mark - Interface
@interface MUOPostsViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) PostsViewModel *viewModel;

@property (nonatomic) BOOL loadingInProgress;
@property (nonatomic, strong) NSMutableArray* posts;

@property (nonatomic) BOOL displayingOfflinePosts;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray* cellCalculcationsCache;
@property (nonatomic, assign) CGSize largeCellSize;
@property (nonatomic, assign) CGSize smallCellSize;

@property (nonatomic, strong) NSDate* lastUpdatedDate;
@property (nonatomic, strong) NSMutableArray* unreadPostIDs;

@end

@implementation MUOPostsViewController

@synthesize lastUpdatedDate = _lastUpdatedDate;

#pragma mark - View lifecycle
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"Feed";
   self.navigationItem.title = @"Feed";
   
   self.viewModel = [PostsViewModel new];
   self.cellCalculcationsCache = [NSMutableArray new];
   self.posts = [NSMutableArray new];
   [self initRefreshControl];
   
   [self.collectionView registerNib:[UINib nibWithNibName:[ReaderSmallCell leftNibName] bundle:nil]
         forCellWithReuseIdentifier:[ReaderSmallCell leftCellID]];
   [self.collectionView registerNib:[UINib nibWithNibName:[ReaderSmallCell rightNibName] bundle:nil]
         forCellWithReuseIdentifier:[ReaderSmallCell rightCellID]];
   [self.collectionView registerNib:[UINib nibWithNibName:[ReaderLargeCell nibName] bundle:nil] forCellWithReuseIdentifier:[ReaderLargeCell cellID]];
   self.collectionView.dataSource = self;
   self.collectionView.delegate = self;
   self.collectionView.delaysContentTouches = NO;
   
   self.loadingInProgress = NO;
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   if (self.posts.count == 0) [self fetchPosts];
   if (self.selectedIndexPath != nil) {
      [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
      self.selectedIndexPath = nil;
   }
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
}


#pragma mark - Calculations
- (void) calculateInitialCellCache {
   NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
   for (int i = 0; i < self.posts.count; i++) {
      [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
   }
   [self calculateHeightsForIndexPaths:indexPaths];
}

- (void) calculateHeightsForIndexPaths:(NSArray *) indexPaths {
   for (NSIndexPath* indexPath in indexPaths) {
      if (indexPath.row % 5 == 0) {
         CGRect labelRect = [ReaderLargeCell labelFrame:self.posts[indexPath.row] cellSize:self.largeCellSize];
         [self.cellCalculcationsCache addObject:[NSValue valueWithCGRect:labelRect]];
      } else {
         int mod = indexPath.row % 5;
         BOOL left = YES;
         if (mod % 2 == 0) {
            left = NO;
         }
         CGFloat width = (screen_width - 3.0) / 2.0 - 26;
         CGFloat height = width / 4.0 * 3.0;
         CGSize imageSize = CGSizeMake(width, height);
         CGRect labelRect = [ReaderSmallCell labelHeightForPost:self.posts[indexPath.row] left:left imageSize:imageSize];
         [self.cellCalculcationsCache addObject:[NSValue valueWithCGRect:labelRect]];
      }
   }
}

-(CGSize)smallCellSize {
   if (CGSizeEqualToSize(CGSizeZero, _smallCellSize)) {
      CGFloat width = (screen_width - 3.0) / 2.0;
      CGFloat height = (width - 26.0) / 4.0 * 3.0 + 124;
      _smallCellSize = CGSizeMake(width, height);
   }
   return _smallCellSize;
}

- (CGSize)largeCellSize {
   if (CGSizeEqualToSize(CGSizeZero, _largeCellSize)) {
      CGFloat width = screen_width;
      CGFloat height = width * 0.7;
      _largeCellSize = CGSizeMake(width, height);
   }
   return _largeCellSize;
}


#pragma mark - Collection view layout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
   //Large cell
   if (indexPath.row % 5 == 0) {
      return self.largeCellSize;
   }
   //Small cell
   return self.smallCellSize;
}

#pragma mark - Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return self.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   Post* presentedPost = self.posts[indexPath.row];
   if (indexPath.row % 5 == 0) {
      ReaderLargeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ReaderLargeCell cellID] forIndexPath:indexPath];
      [cell fillWithPost:presentedPost labelFrame:[self.cellCalculcationsCache[indexPath.row] CGRectValue]];
      return cell;
   }
   ReaderSmallCell* cell;
   int mod = indexPath.row % 5;
   if (mod % 2 == 0) {
      cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ReaderSmallCell rightCellID] forIndexPath:indexPath];
   } else {
      cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ReaderSmallCell leftCellID] forIndexPath:indexPath];
   }
   [cell fillWithPost:presentedPost labelFrame:[self.cellCalculcationsCache[indexPath.row] CGRectValue]];
   return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == self.posts.count - 10 && self.posts.count != 0 && !self.displayingOfflinePosts && !self.loadingInProgress) {
      [self loadMore];
   }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   Post *post = self.posts[indexPath.row];
   
   
   MUOPagingPostsController* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PagingController"];
   postVC.posts = self.posts;
   postVC.postToDisplay = post;
   
   self.selectedIndexPath = indexPath;
   [self.unreadPostIDs removeObject:post.ID];
   [self.navigationController pushViewController:postVC animated:YES];
}

#pragma mark - Server interaction
- (void) loadMore {
   NSNumber* lastPostID = [(Post*)self.posts.lastObject ID];
   self.viewModel.lastPostID = lastPostID;
   [self.viewModel setNextPage];
   [self fetchPosts];
}



- (void) fetchPosts {
   self.loadingInProgress = YES;
   @weakify(self);
   [[self.viewModel fetchPosts] subscribeNext:^(NSArray* posts) {
      @strongify(self);      self.loadingInProgress = NO;
      //[self.refreshControl endRefreshing];
      
      //If newly loaded posts are equal to displayed posts, do nothing
      if (posts.count == 0) {
         return;
      }
      if ([self lastPostIsEqualToPost:posts[0]] && !self.displayingOfflinePosts) {
         return;
      }
      self.displayingOfflinePosts = NO;
      
      NSInteger page = [self.viewModel getPage];
      if (page == 1) {
         [self.posts removeAllObjects];
         [self.cellCalculcationsCache removeAllObjects];
      }
      
      [SDWebImagePrefetcher prefetchAvatarsForPosts:posts];
      [self.posts addObjectsFromArray:posts];
      
      if (page == 1) {
         [self calculateInitialCellCache];
         [self configureUnreadPosts];
         [self.collectionView reloadData];
      } else {
         NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
         NSInteger i = [self.posts count] - [posts count];
         for(NSDictionary __unused *result in posts){
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            i++;
         }
         [self calculateHeightsForIndexPaths:indexPaths];
         [self.collectionView insertItemsAtIndexPaths:indexPaths];
      }
   } error:^(NSError *error) {
      
   }];
}



-(BOOL) lastPostIsEqualToPost:(Post*) post {
   Post* firstPost = [self.posts firstObject];
   if ([firstPost.ID isEqualToNumber:post.ID]) {
      return YES;
   }
   return NO;
}

#pragma mark - Last updated
- (void) configureUnreadPosts {
   self.unreadPostIDs = [NSMutableArray new];
   if (self.lastUpdatedDate != nil) {
      NSDate* lastUpdatedDate = self.lastUpdatedDate;
      for (Post* post in self.posts) {
         if ([post.postDate isLaterThan:lastUpdatedDate]) {
            [self.unreadPostIDs addObject:post.ID];
         } else {
            break;
         }
      }
   }
   self.lastUpdatedDate = [(Post*)self.posts[0] postDate];
}

- (void)setLastUpdatedDate:(NSDate *)lastUpdatedDate {
   _lastUpdatedDate = lastUpdatedDate;
   [[NSUserDefaults standardUserDefaults] setObject:lastUpdatedDate forKey:@"lastUpdated"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastUpdatedDate {
   if (_lastUpdatedDate == nil) {
      _lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdated"];
   }
   return _lastUpdatedDate;
}

#pragma mark - Refreshing
- (void) subscriptionsChanged {
   [self.viewModel resetPage];
   [self fetchPosts];
}

- (void) networkStatusChanged:(NSDictionary *) userInfo {
   AFNetworkReachabilityStatus status = [[[userInfo valueForKey:@"userInfo"] valueForKey:@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
   if (status > 0 && self.posts.count == 0) {
      [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
   }
}

-(void) initRefreshControl {
   self.refreshControl = [[UIRefreshControl alloc] init];
   self.refreshControl.backgroundColor = [UIColor clearColor];
   self.refreshControl.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
   [self.refreshControl addTarget:self
                           action:@selector(refresh)
                 forControlEvents:UIControlEventValueChanged];
   [self.collectionView insertSubview:self.refreshControl atIndex:0];
   self.collectionView.alwaysBounceVertical = YES;
}

-(void) refresh {
   [self.viewModel resetPage];
   [self fetchPosts];
}

@end
