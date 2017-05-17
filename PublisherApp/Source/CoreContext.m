//
//  CoreContext.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "CoreContext.h"
#import "MUOExternalLinksHandler.h"
#import "ReaderSettings.h"
#import "UIFont+Additions.h"
@import AFNetworking;


@implementation CoreContext

+ (instancetype)sharedContext {
   static CoreContext* context;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      context = [CoreContext new];
      
      //Default implementations
      context.linksHandler = [MUOExternalLinksHandler new];
      context.shareHelper = [ShareHelper new];
      context.likesManager = [LikesManager new];
      context.savesManager = [MUOSavesManager new];
      context.navigationRouter = [NavigationRouter new];
      context.savesTitle = @"Saves";
      context.siteURL = @"http://www.makeuseof.com";
      context.cdnPath = @"http://cdn.makeuseof.com";
      context.bottomBarEnabled = YES;
      context.bookmarksEnabled = YES;
   });
   return context;
}

- (void)shouldOpenLinksInApp:(BOOL)inApp {
   [ReaderSettings sharedSettings].shouldOpenLinksInApp = inApp;
}

- (void)appDidFinishLaunching {
   [[AFNetworkReachabilityManager sharedManager] startMonitoring];
   
   [UIFont registerNewFont:@"SourceSansProRegular"];
   [UIFont registerNewFont:@"SourceSansProBold"];
   [UIFont registerNewFont:@"SourceSansPro-Italic"];
   [UIFont registerNewFont:@"SourceSansPro-BoldItalic"];
}

@end
