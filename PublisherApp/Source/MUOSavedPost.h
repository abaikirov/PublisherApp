//
//  SPLMSaves.h
//  MakeUseOf
//
//  Created by AZAMAT on 5/12/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import "Realm/Realm.h"

@interface MUOSavedPost : RLMObject

@property NSInteger ID;
@property NSString *title;
@property NSString *imageUrl;
@property NSString *content;
@property NSDate* date;
@property NSString* primaryCategory;
@property NSString* postURL;
@property NSInteger likesCount;
@property NSString *postAuthor;

@property BOOL isBookmarked;
@property BOOL isOfflineSaved;

- (NSString*) relativeStringFromDate;
- (NSString*) postDate;

@end
