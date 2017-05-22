//
//  ReaderSettings.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/17/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
   ExtraSmall = - 2,
   Small = -1,
   Base = 0,
   Large = 1,
   ExtraLarge = 2
} FontSize;

@interface ReaderSettings : NSObject

+ (instancetype) sharedSettings;

@property (nonatomic) int preferredFontSize;
@property (nonatomic) BOOL shouldOpenLinksInApp;

@end
