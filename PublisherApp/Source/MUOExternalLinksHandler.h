//
//  MUOExternalLinksHandler.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import Foundation;
#import "Post.h"

@interface MUOExternalLinksHandler : NSObject

- (void) handleURL:(NSURL*) url fromViewController:(UIViewController*) vc withPost:(Post*) post;

@end
