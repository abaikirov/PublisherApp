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

- (NSArray *) getImagesFromHTML:(NSString*) htmlString;
- (NSString *) setBodyFontSize:(NSInteger) fontSize forHTML:(NSString *) htmlString;

@end
