//
//  PublisherAppSetupProvider.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 2/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "PublisherAppSetupProvider.h"

@implementation PublisherAppSetupProvider

+ (instancetype)sharedProvider {
   static PublisherAppSetupProvider *provider;
   static dispatch_once_t once_t;
   dispatch_once(&once_t, ^{
      provider = [PublisherAppSetupProvider new];
   });
   return provider;
}

- (NSURL *)sessionManagerBaseURL {
   NSURL* url = [[NSURL alloc] initWithString:@"http://pa.grouvi.org:8082/makeuseof/"];
   return url;
}

- (void)setupHeadersForManager:(AFHTTPSessionManager *)manager {
   
}

- (void)updateHeadersForManager:(AFHTTPSessionManager *)manager {
   
}

@end
