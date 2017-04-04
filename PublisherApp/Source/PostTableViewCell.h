//
//  PostTableViewCell.h
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MUOSavedPost;
@class Post;
@interface PostTableViewCell : UITableViewCell

+ (NSString*) cellID;
+ (CGFloat) cellHeight;
+ (NSBundle*) bundle;

- (void) fillWithPost:(Post*) post;
- (void) fillWithSavedPost:(MUOSavedPost*) post;

@end
