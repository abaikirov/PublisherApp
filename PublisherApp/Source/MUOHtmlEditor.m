//
//  MUOHtmlEditor.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUOHtmlEditor.h"
#import "NSString+MUO.h"
#import "RegExCategories.h"

NSString* cssFontSizePattern = @"font-size:(([^;\"}]*[;\"}]))";
NSString* imgSrcPattern = @"src\\s*=\\s*(\"|')(([^\"';]*))(\"|')";
NSString* bodyPattern = @"<body.*?>";
NSString* classPattern = @"class=\"(.*?)\"";
NSString* bracesPattern = @"\"(.*?)\"";


@interface MUOHtmlEditor()

@property (nonatomic) BOOL shouldIncrease;

@end

@implementation MUOHtmlEditor

+(instancetype)editor {
   static dispatch_once_t once;
   static id instance;
   dispatch_once(&once, ^{
      instance = [self new];
   });
   return instance;
}


#pragma mark - Public methods

-(NSString *)setBodyFontSize:(NSInteger)fontSize forHTML:(NSString *)htmlString {
   NSArray* fontClasses = @[@"super_small_size", @"small_size", @"",@"big_size", @"super_big_size"];
   
   NSString* currentBodyTag = [htmlString matches:RX(bodyPattern)].firstObject;
   NSString* currentBody = [currentBodyTag substringBetweenString:@"<" andString:@">"];
   NSString* classString = [currentBody matches:RX(classPattern)].firstObject;
   NSString* currentClass = [[classString matches:RX(bracesPattern)].firstObject stringByReplacingOccurrencesOfString:@"\"" withString:@""];
   NSString* fontClass = fontClasses[fontSize + 2];
   
   if (currentClass) {
      NSString* newClass = currentClass;
      for (NSString* fontClass in fontClasses) {
         if ([newClass containsString:fontClass]) {
            newClass = [newClass stringByReplacingOccurrencesOfString:fontClass withString:@""];
         }
      }
      newClass = [NSString stringWithFormat:@"%@ %@", newClass, fontClass];
      
      NSString* newBody = [currentBodyTag stringByReplacingOccurrencesOfString:currentClass withString:newClass];
      NSString* newHTMLString = [htmlString stringByReplacingOccurrencesOfString:currentBodyTag withString:newBody];
      
      return newHTMLString;
   }
   
   NSString* newBody = [NSString stringWithFormat:@"<body class=\"%@\">", fontClass];
   NSString* newHTMLString = [htmlString stringByReplacingOccurrencesOfString:currentBodyTag withString:newBody];
   
   return newHTMLString;
}

-(NSArray *)getImagesFromHTML:(NSString *)htmlString {
   NSString* body = nil;
   //If there are groups section below, use wdt_grouvi
   body = [htmlString substringBetweenString:@"<body" andString:@"<div class=\"wdt_grouvi\">"];
   if (!body) {
      body = [htmlString substringBetweenString:@"<body" andString:@"</body>"];
   }
   NSArray* matches = [body matches:RX(imgSrcPattern)];
   
   //Get links from matches
   NSMutableArray* imageLinks = [NSMutableArray new];
   for (NSString* match in matches) {
      if (![match containsString:@"cdn.makeuseof.com"] && ![match containsString:@"file:///"]) {
         continue;
      }
      NSString* imgSrc = [match substringFromIndex:5];
      imgSrc = [imgSrc stringByReplacingOccurrencesOfString:@"\"" withString:@""];
      [imageLinks addObject:imgSrc];
   }
   return imageLinks;
}

@end
