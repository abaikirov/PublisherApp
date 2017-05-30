//
//  MUOHtmlEditor.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUOHtmlEditor : NSObject

+ (instancetype) editor;

- (NSString *) setBodyFontSize:(NSInteger) fontSize forHTML:(NSString *) htmlString;
- (NSString *) increaseFontSizeForHTML:(NSString*) htmlString;
- (NSString *) decreaseFontSizeForHTML:(NSString*) htmlString;

- (NSArray *) getImagesFromHTML:(NSString*) htmlString;
/**
 *  After app updates, Library directory path changing, so we should update path
 *
 *  @param htmlString oldHTMLString
 *
 *  @return newHTMLString
 */
- (NSString*) replaceLocalURLsWithNewLibraryPath:(NSString *) htmlString;
- (NSString *) replaceImagesWithPlaceholder:(NSString *) htmlString;
- (NSString *) addCSS:(NSString*) css toHTML:(NSString *) htmlString;
- (NSString *) removeFeaturedImageBlockFromHTML:(NSString*) htmlString;

@end
