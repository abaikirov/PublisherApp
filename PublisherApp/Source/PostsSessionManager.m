//
//  PostsSessionManager.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 2/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "PostsSessionManager.h"
#import "SessionManagerSetupProvider.h"
#import "PublisherAppSetupProvider.h"

@interface PostsSessionManager()
@property (nonatomic, strong) id<SessionManagerSetupProvider> setupProvider;
@end


@implementation PostsSessionManager

static PostsSessionManager* manager;

+ (PostsSessionManager *)sharedManager {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      id<SessionManagerSetupProvider> provider = [PublisherAppSetupProvider sharedProvider];
      manager = [[PostsSessionManager alloc] initWithBaseURL:[provider sessionManagerBaseURL]];
      [provider setupHeadersForManager:manager];
      manager.setupProvider = provider;
   });
   return manager;
}

+ (void) setupWithProvider:(id<SessionManagerSetupProvider>) provider {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      manager = [[PostsSessionManager alloc] initWithBaseURL:[provider sessionManagerBaseURL]];
   });
   [provider setupHeadersForManager:manager];
   manager.setupProvider = provider;
}

- (void) updateHeaders {
   [self.setupProvider updateHeadersForManager:self];
}

@end
