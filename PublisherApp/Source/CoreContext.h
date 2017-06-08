//
//  CoreContext.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUOExternalLinksHandler.h"
#import "ShareHelper.h"
#import "LikesManager.h"
#import "MUOSavesManager.h"
#import "NavigationRouter.h"

@protocol GroupsOpenerDelegate <NSObject>
- (void) openGroupForPost:(NSNumber*) postID;
@end

@interface CoreContext : NSObject
+ (instancetype) sharedContext;

@property (nonatomic, strong) LikesManager* likesManager;
@property (nonatomic, strong) MUOExternalLinksHandler* linksHandler;
@property (nonatomic, strong) ShareHelper* shareHelper;
@property (nonatomic, strong) MUOSavesManager* savesManager;
@property (nonatomic, strong) NavigationRouter* navigationRouter;
@property (nonatomic, strong) id<GroupsOpenerDelegate> groupOpener;

@property (nonatomic, strong) NSString* siteURL;
@property (nonatomic, strong) NSString* cdnPath;
@property (nonatomic, strong) NSString* savesTitle;

//Grouvi login fields
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* accessToken;
   
@property (nonatomic) BOOL bottomBarEnabled;
@property (nonatomic) BOOL bookmarksEnabled;
@property (nonatomic) BOOL useBlocks;
@property (nonatomic) BOOL commentsEnabled;

- (void) shouldOpenLinksInApp:(BOOL) inApp;
- (void) appDidFinishLaunching;

@end
