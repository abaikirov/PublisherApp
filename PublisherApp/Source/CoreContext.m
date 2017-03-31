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
   });
   return context;
}

- (void)shouldOpenLinksInApp:(BOOL)inApp {
   [ReaderSettings sharedSettings].shouldOpenLinksInApp = inApp;
}

@end
