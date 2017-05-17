//
//  ArticleBlock.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import "ArticleBlock.h"
@import UIColor_HexString;
@import ReactiveCocoa;

@interface ArticleBlock()

@property (nonatomic, strong) NSAttributedString* renderedText;

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

#pragma mark - Text rendering for displaying html
- (NSAttributedString *)prerenderedText {
   if (!self.renderedText) {
      NSMutableAttributedString *htmlString = [[NSMutableAttributedString alloc]initWithData:[self.content dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
      NSRange allStringRange = NSMakeRange(0, htmlString.length);
      [htmlString beginEditing];
      [htmlString enumerateAttribute:NSFontAttributeName inRange:allStringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
         if (value) {
            UIFont *oldFont = (UIFont *)value;
            UIFont* regularFont = [UIFont fontWithName:@"SourceSansPro-Regular" size:19];
            UIFont* boldFont = [UIFont fontWithName:@"SourceSansPro-Bold" size:19];
            
            [htmlString removeAttribute:NSFontAttributeName range:range];
            //replace your font with new
            if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"]) {
               [htmlString addAttribute:NSFontAttributeName value:regularFont range:range];
            } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"]) {
               [htmlString addAttribute:NSFontAttributeName value:boldFont range:range];
            } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"]) {
               UIFont* italic = [UIFont fontWithName:@"SourceSansPro-It" size:19];
               [htmlString addAttribute:NSFontAttributeName value:italic range:range];
            } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"]) {
               UIFont* boldItalic = [UIFont fontWithName:@"SourceSansPro-BoldIt" size:19];
               [htmlString addAttribute:NSFontAttributeName value:boldItalic range:range];
            } else {
               [htmlString addAttribute:NSFontAttributeName value:regularFont range:range];
            }
         }
      }];
      [htmlString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"212121"] range:allStringRange];
      NSMutableParagraphStyle* paragraphStyle = [NSMutableParagraphStyle new];
      [paragraphStyle setLineSpacing:3];
      [htmlString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:allStringRange];
      [htmlString endEditing];
      self.renderedText = htmlString;
   }
   return self.renderedText;
}

@end
