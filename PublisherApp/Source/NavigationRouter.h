//
//  NavigationRouter.h
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "MUOPostContentViewController.h"
#import "Post.h"

@interface NavigationRouter : NSObject

- (void) showSavesControllerFromNavigationController:(UINavigationController*) presenter;
- (void) showPagingControllerWithVC:(UIViewController*) vc fromNavigationController:(UINavigationController *) navCtrl;
- (void) showPost:(Post*) post fromNavigationController:(UINavigationController*) presenter isOffline:(BOOL) isOffline;

- (void) showLocalGallery:(BOOL) isLocal withImages:(NSArray*) images presentingImage:(NSString*) image fromVC:(UIViewController*) vc;

@end
