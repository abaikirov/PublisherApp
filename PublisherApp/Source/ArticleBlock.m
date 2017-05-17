//
//  ArticleBlock.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import "ArticleBlock.h"

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

- (NSAttributedString *)prerenderedText {
   for(NSString *fontfamilyname in [UIFont familyNames])
   {
      NSLog(@"family:'%@'",fontfamilyname);
      for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
      {
         if ([fontName containsString:@"Source Sans"]) {
            
         }
      }
   }
   if (!self.renderedText) {
      NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc]initWithData:[self.content dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
      [attrib beginEditing];
      [attrib enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attrib.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
         if (value) {
            UIFont *oldFont = (UIFont *)value;
            NSLog(@"%@",oldFont.fontName);
            UIFont* newFont = [UIFont fontWithName:@"SourceSansPro-Regular" size:16];
            
            [attrib removeAttribute:NSFontAttributeName range:range];
            //replace your font with new
            if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"])
               [attrib addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
            else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"])
               [attrib addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:range];
            else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"])
               [attrib addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:16] range:range];
            else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"]) {
               UIFont *boldItalicFont = [UIFont fontWithDescriptor:[[[UIFont systemFontOfSize:16] fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:16];
               [attrib addAttribute:NSFontAttributeName value:boldItalicFont range:range];
            }
            else
               [attrib addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
         }
      }];
      [attrib endEditing];
      self.renderedText = attrib;
   }
   return self.renderedText;
}

@end
