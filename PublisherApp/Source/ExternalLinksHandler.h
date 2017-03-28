//
//  ExternalLinksHandler.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "Post.h"

@interface ExternalLinksHandler : NSObject

- (BOOL) canHandleWebviewRequest:(NSURLRequest*) request forViewController:(UIViewController*) vc withPost:(Post*) post;

@end
