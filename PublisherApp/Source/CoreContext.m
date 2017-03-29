//
//  CoreContext.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "CoreContext.h"

@implementation CoreContext

+ (instancetype)sharedContext {
   static CoreContext* context;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      context = [CoreContext new];
      
      //Default implementations
      context.linksHandler = [ExternalLinksHandler new];
      context.shareHelper = [ShareHelper new];
      context.likesManager = [LikesManager new];
      context.savesManager = [MUOSavesManager new];
      context.navigationRouter = [NavigationRouter new];
      context.savesTitle = @"Saves";
   });
   return context;
}

@end
