//
//  BasePostsViewController.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/16/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostsViewModel.h"

@interface BasePostsViewController : UIViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PostsViewModel *viewModel;

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic) BOOL loadingInProgress;

@property (nonatomic, strong) NSMutableArray* posts;
@property (nonatomic) BOOL displayingOfflinePosts;

//Cell calculations
@property (nonatomic, strong) NSMutableArray* cellCalculcationsCache;
@property (nonatomic, assign) CGSize largeCellSize;
@property (nonatomic, assign) CGSize smallCellSize;

@property (nonatomic, strong) NSDate* lastUpdatedDate;
@property (nonatomic, strong) NSMutableArray* unreadPostIDs;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

- (void) setupCollectionView;

- (void) refresh;

- (void) hideEmptyView;

- (void) fetchPosts;
- (void) handleError:(NSError*) error;

- (void) calculateInitialCellCache;

@end
