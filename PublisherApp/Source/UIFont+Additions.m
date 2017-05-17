//
//  UIFont+Additions.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/17/17.
//
//

#import "UIFont+Additions.h"
#import "CoreContext.h"
@import CoreText;

@implementation UIFont (Additions)

+ (void)registerNewFont:(NSString *)fontName {
   NSString * path = [[NSBundle bundleForClass:[CoreContext class]] pathForResource:fontName ofType:@".ttf"];
   NSURL * url = [NSURL fileURLWithPath:path];
   CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
   CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
   NSString * newFontName = (__bridge NSString *)CGFontCopyPostScriptName(newFont);
   CGDataProviderRelease(fontDataProvider);
   CFErrorRef error;
   CTFontManagerRegisterGraphicsFont(newFont, &error);
   CGFontRelease(newFont);
}

@end
