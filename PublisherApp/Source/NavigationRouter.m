//
//  NavigationRouter.m
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "NavigationRouter.h"
#import "MUOPostContentViewController.h"
#import "MUOGalleryViewController.h"

@implementation NavigationRouter

- (UIStoryboard*) storyboard {
   return [UIStoryboard storyboardWithName:@"PublisherApp" bundle:[NSBundle bundleForClass:[self class]]];
}

#pragma mark - Saves
- (void)showSavesControllerFromNavigationController:(UINavigationController *)presenter {
   UIViewController* savesVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"SavesVC"];
   [presenter pushViewController:savesVC animated:YES];
}

#pragma mark - Posts
- (void)showPost:(Post*)post fromNavigationController:(UINavigationController *)presenter isOffline:(BOOL)isOffline {
   MUOPostContentViewController* postVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"PostContentController"];
   postVC.isOffline = isOffline;
   postVC.post = post;
   
   MUOPagingPostsController* pagingVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"PagingController"];
   pagingVC.viewControllerToDisplay = postVC;
   [presenter pushViewController:pagingVC animated:YES];
}

- (void)showPagingControllerWithVC:(UIViewController<PagingControllerPresentable> *)vc fromNavigationController:(UINavigationController *)navCtrl {
   MUOPagingPostsController* pagingVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"PagingController"];
   pagingVC.viewControllerToDisplay = vc;
   [navCtrl pushViewController:pagingVC animated:YES];
}

#pragma mark - Gallery
- (void)showLocalGallery:(BOOL)isLocal withImages:(NSArray *)images presentingImage:(NSString *)image fromVC:(UIViewController *)vc {
   MUOGalleryViewController* galleryVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GalleryVC"];
   [galleryVC fillWithImages:images isLocal:NO currentImage:image];
   [vc presentViewController:galleryVC animated:YES completion:nil];
}

@end
