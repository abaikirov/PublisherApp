//
//  SessionManagerSetupProvider.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/31/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@protocol SessionManagerSetupProvider <NSObject>

+ (instancetype) sharedProvider;
- (NSURL*) sessionManagerBaseURL;
- (void) setupHeadersForManager:(AFHTTPSessionManager*) manager;

/**
 Update headers that should be added to each request
 */
@optional
- (void) updateHeadersForManager:(AFHTTPSessionManager*) manager;

@end
