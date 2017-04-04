//
//  MUOHtmlEditor.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

@import RegExCategories;
#import "CoreContext.h"
#import "MUOHtmlEditor.h"
#import "NSString+MUO.h"

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

-(NSString *)increaseFontSizeForHTML:(NSString *)htmlString {
   self.shouldIncrease = YES;
   return [self editHTMLString:htmlString];
}

-(NSString *)decreaseFontSizeForHTML:(NSString *)htmlString {
   self.shouldIncrease = NO;
   return [self editHTMLString:htmlString];
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
      if (![match containsString:[CoreContext sharedContext].cdnPath] && ![match containsString:@"file:///"]) {
         continue;
      }
      NSString* imgSrc = [match substringFromIndex:5];
      imgSrc = [imgSrc stringByReplacingOccurrencesOfString:@"\"" withString:@""];
      [imageLinks addObject:imgSrc];
   }
   return imageLinks;
}

- (NSString*) replaceLocalURLsWithNewLibraryPath:(NSString *) htmlString {
   NSArray* images = [self getImagesFromHTML:htmlString];
   if (![images.firstObject containsString:@"/post"]) {
      return htmlString;
   }
   NSRange range = [images.firstObject rangeOfString:@"/post"];
   NSString* oldLibraryPath = [images.firstObject substringWithRange:NSMakeRange(0, range.location)];
   NSString* newLibraryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   
   for (NSString* imagePath in images) {
      NSString* newPath = [imagePath stringByReplacingOccurrencesOfString:oldLibraryPath withString:newLibraryPath];
      newPath = [[NSURL fileURLWithPath:newPath] absoluteString];
      htmlString = [htmlString stringByReplacingOccurrencesOfString:imagePath withString:newPath];
   }
   
   return htmlString;
}

-(NSString *)replaceImagesWithPlaceholder:(NSString *)htmlString {
   NSArray* images = [self getImagesFromHTML:htmlString];
   
   NSString* avatarPlaceholder = [[NSBundle mainBundle] pathForResource:@"icon_profile@3x" ofType:@"png"];
   NSString* avatarPlaceholderURL = [NSURL fileURLWithPath:avatarPlaceholder].absoluteString;
   htmlString = [htmlString stringByReplacingOccurrencesOfString:images[0] withString:avatarPlaceholderURL];
   
   NSString* placeholderPath = [[NSBundle mainBundle] pathForResource:@"placeholder250x500" ofType:@"png"];
   NSString* placeholderURL = [NSURL fileURLWithPath:placeholderPath].absoluteString;
   for (int i = 1; i < images.count; i++) {
      NSString* image = images[i];
      htmlString = [htmlString stringByReplacingOccurrencesOfString:image withString:placeholderURL];
   }
   return htmlString;
}

-(NSString *)addCSS:(NSString *)css toHTML:(NSString *)htmlString {
   if (!htmlString) return htmlString;
   NSString* styleString = [htmlString substringBetweenString:@"<style type=\"text/css\">" andString:@"</style>"];
   if (!styleString || styleString.length == 0) {
      NSRange r1 = [htmlString rangeOfString:@"<style type=\"text/css\">"];
      NSMutableString* mutableHTML = [[NSMutableString alloc] initWithString:htmlString];
      [mutableHTML insertString:css atIndex:r1.location + r1.length];
      return mutableHTML;
   }
   return htmlString;
}

#pragma mark - Modifying
-(NSString*) editHTMLString:(NSString*) htmlString {
   NSString* styleString = [htmlString substringBetweenString:@"<style type=\"text/css\">" andString:@"</style>"];
   NSString* newStyleString = [self styleStringAfterEditing:[styleString mutableCopy]];
   NSString* resultHTML = [htmlString stringByReplacingOccurrencesOfString:styleString withString:newStyleString];
   return resultHTML;
}

-(NSString*) styleStringAfterEditing:(NSMutableString*) styleString {
   NSArray* matches = [styleString matchesWithDetails:RX(cssFontSizePattern)];
   for (RxMatchGroup* group in matches) {
      [styleString replaceCharactersInRange:group.range withString:[self modifiedFontString:[group.value mutableCopy]]];
   }
   return styleString;
}


-(NSString*) modifiedFontString:(NSMutableString*) fontString {
   NSString* pixelValue = [fontString substringBetweenString:@":" andString:@"px"];
   if (pixelValue != nil) {
      NSRange valueRange = [fontString rangeOfString:pixelValue];
      NSInteger fontSize = [pixelValue integerValue];
      if (self.shouldIncrease) {
         fontSize += 2;
      } else {
         fontSize -= 2;
      }
      NSString* newFontSizeString = [NSString stringWithFormat:@"%ld", (long)fontSize];
      [fontString replaceCharactersInRange:valueRange withString:newFontSizeString];
   }
   return fontString;
}

@end
