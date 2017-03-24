//
//  ExternalLinksHandler.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "ExternalLinksHandler.h"

@implementation ExternalLinksHandler

- (BOOL)canHandleWebviewRequest:(NSURLRequest *)request forViewController:(UIViewController *)vc withPost:(Post *)post {
   [[UIApplication sharedApplication] openURL:request.URL];
   return YES;
}

@end
