//
//  CoreContext.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExternalLinksHandler.h"
#import "ShareHelper.h"
#import "LikesManager.h"
#import "MUOSavesManager.h"
#import "NavigationRouter.h"

@interface CoreContext : NSObject

@property (nonatomic, strong) LikesManager* likesManager;
@property (nonatomic, strong) ExternalLinksHandler* linksHandler;
@property (nonatomic, strong) ShareHelper* shareHelper;
@property (nonatomic, strong) MUOSavesManager* savesManager;
@property (nonatomic, strong) NavigationRouter* navigationRouter;

@property (nonatomic, strong) NSString* siteURL;

@property (nonatomic, strong) NSString* savesTitle;

+ (instancetype) sharedContext;

- (void) shouldOpenLinksInApp:(BOOL) inApp;

@end
