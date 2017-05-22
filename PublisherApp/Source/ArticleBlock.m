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
   NSMutableAttributedString *htmlString = [[NSMutableAttributedString alloc]initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
   NSRange allStringRange = NSMakeRange(0, htmlString.length);
   [htmlString beginEditing];
   [htmlString enumerateAttribute:NSFontAttributeName inRange:allStringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
      if (value) {
         UIFont *oldFont = (UIFont *)value;
         
         [htmlString removeAttribute:NSFontAttributeName range:range];
         //replace your font with new
         if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:regularFont range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansBold:normalFontSize] range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansItalic:normalFontSize] range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansBoldItalic:normalFontSize] range:range];
         } else {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansRegular:normalFontSize] range:range];
         }
      }
   }];
   [htmlString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"212121"] range:allStringRange];
   [htmlString endEditing];
   return htmlString;
}


#pragma mark - Content
- (NSAttributedString*) listBlockContent {
   NSArray* items = self.properties[@"items"];
   BOOL ordered = [self.properties[@"ordered"] boolValue];
   NSString* bulletType = @"- ";
   NSMutableAttributedString* result = [NSMutableAttributedString new];
   for (NSString* item in items) {
      NSMutableAttributedString* attrItem = [[NSMutableAttributedString alloc] initWithAttributedString:[self htmlStringFromString:item]];
      [attrItem appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
      if (ordered == YES) {
         bulletType = [NSString stringWithFormat:@"%lu. ", [items indexOfObject:item] + 1];
      }
      NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"e22524"],
                                   NSFontAttributeName : [UIFont sourceSansBold:19]};
      NSAttributedString* bullet = [[NSAttributedString alloc] initWithString:bulletType
                                                                   attributes:attributes];
      [attrItem insertAttributedString:bullet atIndex:0];
      [result appendAttributedString:attrItem];
   }
   return result;
}

#pragma mark - Font values
- (CGFloat) baseFontSize {         //Depending on settings
   CGFloat fontSize = 19;
   if ([self.type isEqualToString:kTextBlock]) {
      return [self textBlockFontSize];
   }
   if ([self.type isEqualToString:kHeaderBlock]) {
      fontSize = 22;
   }
   return fontSize;
}

- (CGFloat) textBlockFontSize {
   switch ([ReaderSettings sharedSettings].preferredFontSize) {
      case ExtraSmall:
         return 16;
      case Small:
         return 18;
      case Base:
         return 19;
      case Large:
         return 20;
      case ExtraLarge:
         return 24;
         
      default:
         return 19;
   }
}

@end
