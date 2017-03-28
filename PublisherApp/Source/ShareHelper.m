//
//  ShareHelper.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "ShareHelper.h"

@implementation ShareHelper

- (void)sharePostWithURL:(NSURL *)url title:(NSString *)title presentingViewController:(UIViewController *)vc fromView:(UIView *)view {
   if (!title || !url) { //nil values can cause a crash
      return;
   }
   
   NSString* activityString = [NSString stringWithFormat:@"%@", url.absoluteString];
   UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                           initWithActivityItems:@[activityString]
                                           applicationActivities:nil];
   activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
   [activityVC setValue:title forKey:@"Subject"];
   
   if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
      activityVC.popoverPresentationController.sourceView = view;
   }
   [vc presentViewController:activityVC animated:YES completion:nil];
}

- (void)sharePostToWhatsapp:(Post *)post {
   NSString* shareText = [NSString stringWithFormat:@"whatsapp://send?text=%@", post.url];
   shareText = [shareText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
   NSURL *whatsappURL = [NSURL URLWithString:shareText];
   if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
      [[UIApplication sharedApplication] openURL:whatsappURL options:@{} completionHandler:nil];
   }
}

- (void)sharePostToTwitter:(Post *)post fromVC:(UIViewController *)vc{
   
}

- (void)sharePostToFacebook:(Post *)post fromVC:(UIViewController *)vc{
   
}

- (void)sharePostToFBMessenger:(Post *)post fromVC:(UIViewController *)vc{
   
}

@end
