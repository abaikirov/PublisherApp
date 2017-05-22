//
//  MUOExternalLinksHandler.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "MUOExternalLinksHandler.h"
#import "MUOPostContentViewController.h"
#import "MUOGalleryViewController.h"
#import "MUOHtmlEditor.h"
#import "CoreContext.h"
#import "ReaderSettings.h"
#import "MUOGalleryViewController.h"
#import "BlocksContentController.h"
@import SafariServices;

@interface MUOExternalLinksHandler()

@property (nonatomic, strong) MUOHtmlEditor* htmlEditor;


@end

@implementation MUOExternalLinksHandler

- (void)handleURL:(NSURL *)url fromViewController:(UIViewController *)vc withPost:(Post *)post {
   NSString* urlString = [url absoluteString];
   self.htmlEditor = [MUOHtmlEditor editor];
   
   if ([urlString hasPrefix:[CoreContext sharedContext].siteURL]) {
      UIViewController<PagingControllerPresentable>* postVC = [self contentControllerWithPostURL:urlString fromVC:vc];
      [[CoreContext sharedContext].navigationRouter showPagingControllerWithVC:postVC fromNavigationController:vc.navigationController];
   }else if ([urlString hasPrefix:[CoreContext sharedContext].cdnPath]) {
      NSArray* images = [self.htmlEditor getImagesFromHTML:post.html];
      [[CoreContext sharedContext].navigationRouter showLocalGallery:NO withImages:images
                                                     presentingImage:urlString fromVC:vc.parentViewController];
   } else if ([urlString hasPrefix:@"file:///"]) {
      NSArray* images = [self.htmlEditor getImagesFromHTML:post.html];
      [[CoreContext sharedContext].navigationRouter showLocalGallery:YES withImages:images
                                                     presentingImage:urlString fromVC:vc.parentViewController];
   } else {
      if ([ReaderSettings sharedSettings].shouldOpenLinksInApp) {
         SFSafariViewController* safari = [[SFSafariViewController alloc] initWithURL:url];
         [vc.parentViewController presentViewController:safari animated:YES completion:nil];
      } else {
         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
      }
   }
}

- (UIViewController<PagingControllerPresentable>*) contentControllerWithPostURL:(NSString*)url fromVC:(UIViewController*) vc {
   /*if ([CoreContext sharedContext].useBlocks) {
      BlocksContentController* blocksVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"BlocksVC"];
      return blocksVC;
   } else {*/
      MUOPostContentViewController* postVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"PostContentController"];
      postVC.postSlug = url;
      return postVC;
   //}
}

@end
