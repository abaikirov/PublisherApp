//
//  PublisherAppSetupProvider.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 2/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "PublisherAppSetupProvider.h"

@interface PublisherAppSetupProvider()

@property (nonatomic, strong) NSURL* baseURL;

@end

@implementation PublisherAppSetupProvider

+ (instancetype)sharedProvider {
   static PublisherAppSetupProvider *provider;
   static dispatch_once_t once_t;
   dispatch_once(&once_t, ^{
      provider = [PublisherAppSetupProvider new];
   });
   return provider;
}


+ (void) setBaseURL:(NSString*) url {
   [PublisherAppSetupProvider sharedProvider].baseURL = [[NSURL alloc] initWithString:url];
}

- (NSURL *)sessionManagerBaseURL {
   return self.baseURL;
}

- (void)setupHeadersForManager:(AFHTTPSessionManager *)manager {
   
}

- (void)updateHeadersForManager:(AFHTTPSessionManager *)manager {
   
}

@end
