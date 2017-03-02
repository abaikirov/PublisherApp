//
//  PostsSessionManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 2/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "AFNetworking.h"
#import "SessionManagerSetupProvider.h"

@interface PostsSessionManager : AFHTTPSessionManager

+ (PostsSessionManager*) sharedManager;

+ (void) setupWithProvider:(id<SessionManagerSetupProvider>) provider;
- (void) updateHeaders;

@end
