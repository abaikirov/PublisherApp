//
//  MUOExternalLinksHandler.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/20/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "ExternalLinksHandler.h"

@interface MUOExternalLinksHandler : ExternalLinksHandler

-(void) handleExternalURL:(NSURL*) url forViewController:(UIViewController*) vc;

@end
