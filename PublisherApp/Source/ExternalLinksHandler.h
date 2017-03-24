//
//  ExternalLinksHandler.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Post.h"

@interface ExternalLinksHandler : NSObject

- (BOOL) canHandleWebviewRequest:(NSURLRequest*) request forViewController:(UIViewController*) vc withPost:(Post*) post;

@end
