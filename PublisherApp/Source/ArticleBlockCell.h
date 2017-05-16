//
//  ArticleBlockCell.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import <UIKit/UIKit.h>
#import "ArticleBlock.h"


@class Post;
#pragma mark - Base block cell
@protocol ArticleBlockCell<NSObject>
+(NSString*) reuseIdentifier;
@optional
- (void) fillWithBlock:(ArticleBlock*) block;
@end

@interface ArticleHeaderCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UIImageView *featuredImage;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (void) fillWithPost:(Post*) post;
@end

@interface TextBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UILabel *textBlockLabel;
@end

@interface ImageBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@end
