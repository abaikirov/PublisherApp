//
//  PostTableViewCell.h
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MUOSavedPost;
@interface PostTableViewCell : UITableViewCell

+ (NSString*) cellID;
+ (CGFloat) cellHeight;
+ (NSBundle*) bundle;

- (void) fillWithSavedPost:(MUOSavedPost*) post;

@end
