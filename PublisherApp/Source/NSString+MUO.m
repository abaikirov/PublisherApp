//
//  NSString+MUO.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 7/27/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "NSString+MUO.h"

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

@end
