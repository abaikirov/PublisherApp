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

@interface CoreContext : NSObject

@property (nonatomic, strong) LikesManager* likesManager;
@property (nonatomic, strong) ExternalLinksHandler* linksHandler;
@property (nonatomic, strong) ShareHelper* shareHelper;
@property (nonatomic, strong) MUOSavesManager* savesManager;

+ (instancetype) sharedContext;

@end
