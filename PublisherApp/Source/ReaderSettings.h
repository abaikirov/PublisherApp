//
//  ReaderSettings.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/17/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderSettings : NSObject

+ (instancetype) sharedSettings;

@property (nonatomic) int preferredFontSize;

@end
