//
//  UserSettings.h
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 1/19/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

+ (instancetype) sharedSettings;

@property (nonatomic) int preferredFontSize;

@end
