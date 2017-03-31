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
#import "MUOSavesViewController.h"
#import "SavesViewModel.h"
#import "MUOSavedPost.h"
#import "PostTableViewCell.h"
#import "CoreContext.h"

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
   self.title = [CoreContext sharedContext].savesTitle;
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

@end
