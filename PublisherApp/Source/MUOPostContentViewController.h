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


@interface MUOPostContentViewController : UIViewController <UIWebViewDelegate, PagingControllerPresentable>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Post* post;
@property (strong, nonatomic) NSNumber *postID;
@property (strong, nonatomic) NSString* postSlug;
@property (nonatomic) BOOL isOffline;

@end
