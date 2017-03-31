//
//  ReaderSettings.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/17/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "ReaderSettings.h"

static NSString* kFontKey = @"font_size";
static NSString* inAppKey = @"in_app";

@implementation ReaderSettings

+ (instancetype)sharedSettings {
   static ReaderSettings* settings;
   static dispatch_once_t once;
   dispatch_once(&once, ^{
      settings = [ReaderSettings new];
      [settings restoreSettings];
   });
   return settings;
}

- (void)setPreferredFontSize:(int)preferredFontSize {
   _preferredFontSize = preferredFontSize;
   [[NSUserDefaults standardUserDefaults] setInteger:preferredFontSize forKey:kFontKey];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setShouldOpenLinksInApp:(BOOL)shouldOpenLinksInApp {
   _shouldOpenLinksInApp = shouldOpenLinksInApp;
   [[NSUserDefaults standardUserDefaults] setBool:shouldOpenLinksInApp forKey:inAppKey];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) restoreSettings {
   _preferredFontSize = -1;
   id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kFontKey];
   if (obj != nil) {
      _preferredFontSize = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kFontKey];
   }
   
   if (![[NSUserDefaults standardUserDefaults] boolForKey:inAppKey]) {
      _shouldOpenLinksInApp = YES;
   } else {
      _shouldOpenLinksInApp = [[NSUserDefaults standardUserDefaults] boolForKey:inAppKey];
   }
}



@end
