//
//  UIFont+Additions.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/17/17.
//
//

#import <UIKit/UIKit.h>

@interface UIFont (Additions)

+ (void) registerNewFont:(NSString*) fontName;

//Source sans font
+ (UIFont*) sourceSansRegular:(CGFloat) fontSize;
+ (UIFont*) sourceSansItalic:(CGFloat) fontSize;
+ (UIFont*) sourceSansBold:(CGFloat) fontSize;
+ (UIFont*) sourceSansBoldItalic:(CGFloat) fontSize;

@end
