//
//  NSString+MUO.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "NSString+MUO.h"
#import "UIFont+Additions.h"
#import "NSBundle+PublisherApp.h"
@import UIColor_HexString;

@implementation NSString (MUO)


-(NSString *)substringBetweenString:(NSString *)firstString andString:(NSString *)secondString {
    NSRange r1 = [self rangeOfString:firstString];
    NSRange r2 = [self rangeOfString:secondString];
    
    if (r1.length == 0 || r1.length == NSNotFound || r2.length == 0 || r2.length == NSNotFound) {
        return nil;
    }
    
    
    NSRange substringRange = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    NSString* result = [self substringWithRange:substringRange];
    return result;
}


- (BOOL)containsTag {
   if ([self containsString:@"<"]) {
      if ([self containsString:@"</"] || [self containsString:@"/>"] || [self containsString:@">"]) {
         return YES;
      }
   }
   return NO;
}

- (NSAttributedString *)htmlStringWithFontSize:(CGFloat)fontSize {
   NSMutableAttributedString *htmlString = [[NSMutableAttributedString alloc]initWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
   NSRange allStringRange = NSMakeRange(0, htmlString.length);
   [htmlString beginEditing];
   [htmlString enumerateAttribute:NSFontAttributeName inRange:allStringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
      if (value) {
         UIFont *oldFont = (UIFont *)value;
         
         [htmlString removeAttribute:NSFontAttributeName range:range];
         //replace your font with new
         if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansRegular:fontSize] range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansBold:fontSize] range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansItalic:fontSize] range:range];
         } else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"]) {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansBoldItalic:fontSize] range:range];
         } else {
            [htmlString addAttribute:NSFontAttributeName value:[UIFont sourceSansRegular:fontSize] range:range];
         }
      }
   }];
   [htmlString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"212121"] range:allStringRange];
   [htmlString endEditing];
   return htmlString;
}

- (NSString *)muoLocalized {
   return NSLocalizedStringFromTableInBundle(self, @"Localizable", [NSBundle publisherBundle], @"");
}

@end
