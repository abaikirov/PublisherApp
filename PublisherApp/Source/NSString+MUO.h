//
//  NSString+MUO.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MUO)

-(NSString*) substringBetweenString:(NSString*) firstString andString:(NSString*) secondString;

@end