//
//  ShareHelper.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
@import UIKit;

@interface ShareHelper : NSObject

- (void) sharePostWithURL:(NSURL*) url title:(NSString*) title presentingViewController:(UIViewController*) vc fromView:(UIView*) view;

- (void) sharePostToWhatsapp:(Post*) post;
- (void) sharePostToFacebook:(Post*) post fromVC:(UIViewController*) vc;
- (void) sharePostToFBMessenger:(Post*) post fromVC:(UIViewController*) vc;
- (void) sharePostToTwitter:(Post*) post fromVC:(UIViewController*) vc;


@end
