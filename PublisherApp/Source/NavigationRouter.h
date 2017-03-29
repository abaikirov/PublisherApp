//
//  NavigationRouter.h
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "Post.h"

@interface NavigationRouter : NSObject

- (void) showSavesControllerFromNavigationController:(UINavigationController*) presenter;
- (void) showPost:(Post*) post fromNavigationController:(UINavigationController*) presenter isOffline:(BOOL) isOffline;

@end
