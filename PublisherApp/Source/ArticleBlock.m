//
//  ArticleBlock.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import "ArticleBlock.h"
#import "UIFont+Additions.h"
#import "ReaderSettings.h"
#import "NSString+MUO.h"
@import UIColor_HexString;
@import ReactiveCocoa;

@interface ArticleBlock()

@property (nonatomic, strong) NSAttributedString* prerenderedText;
@property (nonatomic) FontSize appliedFontSize;

@end

@implementation ArticleBlock

- (CGFloat) blockHeight {
   if ([self.type isEqualToString:kImageBlock]) {
      CGFloat imageHeight = [self.properties[@"height"] floatValue];
      CGFloat imageWidth = [self.properties[@"width"] floatValue];
      CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
      CGFloat blockHeight = screen_width * imageHeight / imageWidth;
      return blockHeight;
   }
   return 0;
}

- (BOOL) canDisplayLink {
   if ([self.type isEqualToString:kTextBlock] || [self.type isEqualToString:kListBlock] || [self.type isEqualToString:kHeaderBlock]) {
      return YES;
   }
   return NO;
}

- (NSString *)image {
   return self.properties[@"url"];
}

#pragma mark - Text rendering for displaying html
- (NSAttributedString *)prerenderedText {
   if (!_prerenderedText) {
      [self prerenderText];
   }
   return _prerenderedText;
}

- (void) prerenderText {
   if (!_prerenderedText || (self.appliedFontSize != [ReaderSettings sharedSettings].preferredFontSize)) {
      if ([self.type isEqualToString:kListBlock]) {
         _prerenderedText = [self listBlockContent];
      } else {
         _prerenderedText = [self htmlStringFromString:self.content];
      }
      self.appliedFontSize = [ReaderSettings sharedSettings].preferredFontSize;
   }
}

- (NSAttributedString*) htmlStringFromString:(NSString*) string {
   CGFloat normalFontSize = [self baseFontSize];
   UIFont* regularFont = [UIFont sourceSansRegular:normalFontSize];
   if ([self.type isEqualToString:kHeaderBlock]) {
      regularFont = [UIFont sourceSansBold:normalFontSize];
   }
   
   if (![string containsTag]) {
      NSDictionary* attributes = @{NSFontAttributeName:regularFont, NSForegroundColorAttributeName:[UIColor colorWithHexString:@"212121"]};
      NSAttributedString* result = [[NSAttributedString alloc] initWithString:string attributes:attributes];
      return result;
   } else {
      return [string htmlStringWithFontSize:normalFontSize];
   }
}

#pragma mark - Content
- (NSAttributedString*) listBlockContent {
   NSArray* items = self.properties[@"items"];
   BOOL ordered = [self.properties[@"ordered"] boolValue];
   NSString* bulletType = @"- ";
   NSMutableAttributedString* result = [NSMutableAttributedString new];
   for (NSString* item in items) {
      if (ordered == YES) {
         bulletType = [NSString stringWithFormat:@"%u. ", [items indexOfObject:item] + 1];
      }
      NSString* listItem = [NSString stringWithFormat:@"%@%@", bulletType, item];
      NSMutableAttributedString* attrItem = [[NSMutableAttributedString alloc] initWithAttributedString:[self htmlStringFromString:listItem]];
      NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"e22524"],
                                   NSFontAttributeName : [UIFont sourceSansBold:[self baseFontSize]]};
      [attrItem addAttributes:attributes range:NSMakeRange(0, 2)];
   }
   return result;
}

#pragma mark - Font values
- (CGFloat) baseFontSize {         //Depending on settings
   CGFloat fontSize = 19;
   if ([self.type isEqualToString:kTextBlock] || [self.type isEqualToString:kListBlock]) {
      return [self textBlockFontSize];
   }
   if ([self.type isEqualToString:kHeaderBlock]) {
      return [self headerBlockSize];
   }
   return fontSize;
}

- (CGFloat) textBlockFontSize {
   NSArray* fontSizes = @[@(16), @(18), @(19), @(20), @(24)];
   FontSize currentSize = [ReaderSettings sharedSettings].preferredFontSize;
   return [fontSizes[currentSize + 2] integerValue];
}

- (CGFloat) headerBlockSize {
   NSArray* fontSizes = @[@(19), @(21), @(22), @(23), @(25)];
   FontSize currentSize = [ReaderSettings sharedSettings].preferredFontSize;
   return [fontSizes[currentSize + 2] integerValue];
}

@end
