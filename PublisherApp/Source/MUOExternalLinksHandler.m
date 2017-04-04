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
@import SafariServices;

@interface MUOExternalLinksHandler()

@property (nonatomic, strong) MUOHtmlEditor* htmlEditor;


@end

@implementation MUOExternalLinksHandler

- (BOOL)canHandleWebviewRequest:(NSURLRequest *)request forViewController:(UIViewController *)vc withPost:(Post *)post {
   NSString* urlString = [request.URL absoluteString];
   self.htmlEditor = [MUOHtmlEditor editor];
   
   if ([urlString hasPrefix:[CoreContext sharedContext].siteURL]) {
      MUOPostContentViewController* postVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"PostContentController"];
      postVC.postSlug = urlString;
      [[CoreContext sharedContext].navigationRouter showPagingControllerWithVC:postVC fromNavigationController:vc.navigationController];
   } else if ([urlString hasPrefix:[CoreContext sharedContext].cdnPath]) {
      MUOGalleryViewController* galleryVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"GalleryVC"];
      NSArray* images = [self.htmlEditor getImagesFromHTML:post.html];
      [galleryVC fillWithImages:images isLocal:NO currentImage:urlString];
      [vc.parentViewController presentViewController:galleryVC animated:YES completion:nil];
   } else if ([urlString hasPrefix:@"file:///"]) {
      MUOGalleryViewController* galleryVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"GalleryVC"];
      NSArray* images = [self.htmlEditor getImagesFromHTML:post.html];
      [galleryVC fillWithImages:images isLocal:YES currentImage:urlString];
      [vc.parentViewController presentViewController:galleryVC animated:YES completion:nil];
   } else {
      if ([ReaderSettings sharedSettings].shouldOpenLinksInApp) {
         SFSafariViewController* safari = [[SFSafariViewController alloc] initWithURL:request.URL];
         [vc.parentViewController presentViewController:safari animated:YES completion:nil];
      } else {
         [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
      }
   }
   
   return YES;
}



@end
