//
//  NavigationRouter.m
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "NavigationRouter.h"
#import "MUOPostContentViewController.h"

@implementation NavigationRouter

- (void)showSavesControllerFromNavigationController:(UINavigationController *)presenter {
   UIViewController* savesVC = [[UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"SavesVC"];
   [presenter pushViewController:savesVC animated:YES];
}


- (void)showPost:(Post*)post fromNavigationController:(UINavigationController *)presenter isOffline:(BOOL)isOffline {
   MUOPostContentViewController* postVC = [[UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"PostContentController"];
   postVC.isOffline = isOffline;
   postVC.post = post;
   
   MUOPagingPostsController* pagingVC = [[UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[MUOPagingPostsController class]]] instantiateViewControllerWithIdentifier:@"PagingController"];
   pagingVC.viewControllerToDisplay = postVC;
   [presenter pushViewController:pagingVC animated:YES];
}

- (void)showPagingControllerWithVC:(MUOPostContentViewController *)vc fromNavigationController:(UINavigationController *)navCtrl {
   MUOPagingPostsController* pagingVC = [[UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[MUOPagingPostsController class]]] instantiateViewControllerWithIdentifier:@"PagingController"];
   pagingVC.viewControllerToDisplay = vc;
   [navCtrl pushViewController:pagingVC animated:YES];
}

@end
