//
//  UserSettings.m
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 1/19/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "UserSettings.h"

static NSString* kFontKey = @"font_size";

@implementation UserSettings

+ (instancetype)sharedSettings {
   static UserSettings* settings;
   static dispatch_once_t once;
   dispatch_once(&once, ^{
      settings = [UserSettings new];
      [settings restoreSettings];
   });
   return settings;
}

- (void)setPreferredFontSize:(int)preferredFontSize {
   _preferredFontSize = preferredFontSize;
   [[NSUserDefaults standardUserDefaults] setInteger:preferredFontSize forKey:@"font_size"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) restoreSettings {
   _preferredFontSize = -1;
   id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kFontKey];
   if (obj != nil) {
      _preferredFontSize = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"font_size"];
   }
}

@end
