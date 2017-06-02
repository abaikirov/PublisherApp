//
//  SPLMSavesViewController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/15/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

@import SDWebImage;
@import UIColor_HexString;
@import ReactiveCocoa;
@import SafariServices;
#import "MUOSavesViewController.h"
#import "SavesViewModel.h"
#import "MUOSavedPost.h"
#import "PostTableViewCell.h"
#import "CoreContext.h"
#import "NSString+MUO.h"

@interface MUOSavesViewController ()
@property(nonatomic) SavesViewModel *viewModel;
@property(nonatomic) NSInteger selectedPostId;
@end


@implementation MUOSavesViewController

#pragma mark - view lifecycle
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
   self.navigationItem.title = [CoreContext sharedContext].savesTitle;
   self.title = [[CoreContext sharedContext].savesTitle muoLocalized];
   self.viewModel = [SavesViewModel new];
   
   self.savesTableView.dataSource = self;
   self.savesTableView.delegate = self;
   self.savesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   [self.savesTableView registerNib:[UINib nibWithNibName:@"PostTableViewCell" bundle:[PostTableViewCell bundle]] forCellReuseIdentifier:[PostTableViewCell cellID]];
   
   @weakify(self);
   [[RACObserve(self.viewModel, saves) ignore:nil] subscribeNext:^(NSArray* saves) {
      @strongify(self);
      [self.savesTableView reloadData];
   }];
}

-(void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   [self.viewModel loadSavesFromCache];
   if (![self isSynced]) {
      [self showSyncButton];
      [self syncBookmarks];
   }
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.viewModel.saves.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   MUOSavedPost *savedPost = self.viewModel.saves[indexPath.row];
   PostTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[PostTableViewCell cellID]];
   [cell fillWithSavedPost:savedPost];
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   MUOSavedPost *savedPost = self.viewModel.saves[indexPath.row];
   Post* postToDisplay = [Post postWithSavedPost:savedPost];
   [[CoreContext sharedContext].navigationRouter showPost:postToDisplay fromNavigationController:self.navigationController isOffline:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return [PostTableViewCell cellHeight];
}


#pragma mark - Syncing
- (BOOL) isSynced {
   return [[NSUserDefaults standardUserDefaults] boolForKey:@"bookmarks_synced"];
}

- (void) setBookmarksSyncedFlag {
   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bookmarks_synced"];
}

- (void) syncBookmarks {
   @weakify(self);
   [[self.viewModel syncSaves] subscribeNext:^(NSArray* posts) {
      @strongify(self);
      [self.savesTableView reloadData];
      if (posts.count != 0) {
         [self setBookmarksSyncedFlag];
         self.navigationItem.rightBarButtonItem = nil;
      }
   }];
}

- (void) showSyncButton {
   UIBarButtonItem* syncItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStylePlain target:self action:@selector(handleSync)];
   self.navigationItem.rightBarButtonItem = syncItem;
}

- (void) handleSync {
   NSString* userURL = [NSString stringWithFormat:@"https://api.makeuseof.com/v1/bookmarks/login?user_id=%@", [CoreContext sharedContext].userID];
   SFSafariViewController* safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:userURL]];
   [self presentViewController:safari animated:YES completion:nil];
}

@end
