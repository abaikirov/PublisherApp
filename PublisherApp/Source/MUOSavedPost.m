//
//  SPLMSaves.m
//  MakeUseOf
//
//  Created by AZAMAT on 5/12/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "MUOSavedPost.h"
@import DateTools;

@implementation MUOSavedPost


+(NSString *)primaryKey {
    return [NSString stringWithFormat:@"ID"];
}

- (NSString *)postDate {
   return [self.date formattedDateWithFormat:@"MMMM dd, YYYY"];
}

@end
