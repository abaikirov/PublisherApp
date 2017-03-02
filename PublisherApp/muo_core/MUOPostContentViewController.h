//
//  SPLMPostContentViewController.h
//  MakeUseOf
//
//  Created by AZAMAT on 4/22/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUOPagingPostsController.h"

@class Post;
@class PostContentBottomView;
@class MUOSavedPost;
@interface MUOPostContentViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Post* post;

@property (nonatomic) BOOL isOffline;

@property (nonatomic, weak) UINavigationItem* parentNavigationItem;

@property (nonatomic) NSInteger pageIndex;

@property (nonatomic, weak) MUOPagingPostsController* pagingController;

@end
