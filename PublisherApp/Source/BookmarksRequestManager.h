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

- (RACSignal *) bookmarkPostsWithIDs:(NSArray *) postsID;
- (RACSignal *) deleteBookmarkedPostsWithIDs:(NSArray *)postsID;
- (RACSignal *) fetchBookmarks:(NSArray *) bookmarkIDs;

@end
