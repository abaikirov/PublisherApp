//
//  PublisherAppSetupProvider.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 2/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionManagerSetupProvider.h"

@interface PublisherAppSetupProvider : NSObject<SessionManagerSetupProvider>

+(void) setBaseURL:(NSString*) url;

@end
