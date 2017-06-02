//
//  BookmarksRequestManager.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 3/14/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ReactiveCocoa;

@interface BookmarksRequestManager : NSObject

- (RACSignal*) syncBookmarks;

- (void) addBookmark:(NSString*) postID;
- (void) deleteBookmark:(NSString*) postID;


@end
