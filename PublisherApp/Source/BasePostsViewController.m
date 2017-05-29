//
//  BasePostsViewController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/16/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import SDWebImage;
@import AFNetworking;
@import UIColor_HexString;
@import DateTools;

#import "PostsViewModel.h"
#import "Post.h"
#import "SDWebImagePrefetcher+MUO.h"
#import "MUOPagingPostsController.h"
#import "SmallPostCollectionViewCell.h"
#import "LargePostCollectionViewCell.h"
#import "BasePostsViewController.h"
#import "MUONavigationController.h"
#import "SearchViewController.h"
#import "CoreContext.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height


@interface BasePostsViewController ()

@end

@implementation BasePostsViewController

@synthesize lastUpdatedDate = _lastUpdatedDate;

#pragma mark - View lifecycle
- (UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleDefault;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
   return YES;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   
   self.viewModel = [PostsViewModel new];
   self.cellCalculcationsCache = [NSMutableArray new];
   self.posts = [NSMutableArray new];
   [self initRefreshControl];

   self.collectionView.dataSource = self;
   self.collectionView.delegate = self;
   [self setupCollectionView];
   
   self.loadingInProgress = NO;
   [self setupTabBar];
}

- (void) setupCollectionView {
   NSBundle* bundle = [NSBundle bundleForClass:[self class]];
   [self.collectionView registerNib:[UINib nibWithNibName:[SmallPostCollectionViewCell nibName] bundle:bundle]
         forCellWithReuseIdentifier:[SmallPostCollectionViewCell cellID]];
   [self.collectionView registerNib:[UINib nibWithNibName:[LargePostCollectionViewCell nibName] bundle:bundle] forCellWithReuseIdentifier:[LargePostCollectionViewCell cellID]];
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   if (self.posts.count == 0) [self fetchPosts];
   if (self.selectedIndexPath != nil) {
      [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
      self.selectedIndexPath = nil;
   }
}

#pragma mark - Tab bar
- (void) setupTabBar {
   UIImage* menuImage = [UIImage imageNamed:@"menu" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
   UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
   self.navigationItem.leftBarButtonItem = menuItem;
}

- (void) showSearch {
   /*SearchViewController* searchController = [SearchViewController new];
   MUONavigationController* navCtrl = [[MUONavigationController alloc] initWithRootViewController:searchController];
   
   navCtrl.view.frame = CGRectMake(-screen_width, 0, screen_width, screen_height);
   [[UIApplication sharedApplication].keyWindow addSubview:navCtrl.view];
   [UIView animateWithDuration:0.3 animations:^{
      navCtrl.view.frame = CGRectMake(0, 0, screen_width, screen_height);
   } completion:^(BOOL finished) {
      [self presentViewController:navCtrl animated:NO completion:nil];
   }];*/
   [[CoreContext sharedContext].navigationRouter showSavesControllerFromNavigationController:self.navigationController];
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
         CGRect labelRect = [LargePostCollectionViewCell labelFrame:self.posts[indexPath.row] cellSize:self.largeCellSize];
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
         CGRect labelRect = [SmallPostCollectionViewCell labelHeightForPost:self.posts[indexPath.row] left:left imageSize:imageSize];
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


#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return self.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   Post* presentedPost = self.posts[indexPath.row];
   
   UICollectionViewCell<PostRepresentable>* cell;
   
   if (indexPath.row % 5 == 0) {
      cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LargePostCollectionViewCell cellID] forIndexPath:indexPath];
   } else {
      cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SmallPostCollectionViewCell cellID] forIndexPath:indexPath];
      int mod = indexPath.row % 5;
      if (mod % 2 == 0) {
         [(SmallPostCollectionViewCell*)cell setAlignment:CellAlignmentRight];
      } else {
         [(SmallPostCollectionViewCell*)cell setAlignment:CellAlignmentLeft];
      }
   }
   [cell fillWithPost:presentedPost labelFrame:[self.cellCalculcationsCache[indexPath.row] CGRectValue]];
   if ([self.unreadPostIDs containsObject:presentedPost.ID]) {
      if ([cell isKindOfClass:[SmallPostCollectionViewCell class]]) {
         [(SmallPostCollectionViewCell*)cell markAsNew];
      }
   }
   return cell;
}

- (void)hideEmptyView {
   
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == self.posts.count - 10 && self.posts.count != 0 && !self.displayingOfflinePosts && !self.loadingInProgress) {
      [self loadMore];
   }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
   
   Post *post = self.posts[indexPath.row];
   MUOPagingPostsController* postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PagingController"];
   postVC.posts = self.posts;
   postVC.postToDisplay = post;
   
   self.selectedIndexPath = indexPath;
   [self.unreadPostIDs removeObject:post.ID];
   
   //Preload view controller and highlight here
   postVC.view.alpha = 1;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.06 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      cell.backgroundColor = [UIColor whiteColor];
      [self.navigationController pushViewController:postVC animated:YES];
   });
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
   if (self.viewModel.getPage == 1 && self.posts.count == 0) {
      //[self.navigationController.view showHUD];
   }
   @weakify(self);
   [[self.viewModel fetchPosts] subscribeNext:^(NSArray* posts) {
      @strongify(self);
      //[self.navigationController.view hideHUD];
      self.loadingInProgress = NO;
      [self hideEmptyView];
      [self.refreshControl endRefreshing];
      
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
      @strongify(self);
      [self handleError:error];
   }];
}

- (void)handleError:(NSError *)error {
   
}

#pragma mark - Last updated
-(BOOL) lastPostIsEqualToPost:(Post*) post {
   Post* firstPost = [self.posts firstObject];
   if ([firstPost.ID isEqualToNumber:post.ID]) {
      return YES;
   }
   return NO;
}

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
- (void) networkStatusChanged:(NSDictionary *) userInfo {
   AFNetworkReachabilityStatus status = [[[userInfo valueForKey:@"userInfo"] valueForKey:@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
   if (status > 0 && self.posts.count == 0) {
      [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
   }
}

-(void) initRefreshControl {
   self.refreshControl = [[UIRefreshControl alloc] init];
   self.refreshControl.backgroundColor = [UIColor clearColor];
   //self.refreshControl.tintColor = [[MUOUserSession sharedSession].colorSchemeManager.progressBarColor colorWithAlphaComponent:0.6];
   self.refreshControl.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
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
