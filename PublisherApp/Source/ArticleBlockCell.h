//
//  ArticleBlockCell.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import <UIKit/UIKit.h>
#import "ArticleBlock.h"
@import TTTAttributedLabel;

@class Post;

#pragma mark - Base block cell

@protocol LinkTapDelegate <NSObject>
@optional
- (void) linkTapped:(NSURL*) url;
@end


@protocol ArticleBlockCell<NSObject>
+(NSString*) reuseIdentifier;
@optional
- (void) fillWithBlock:(ArticleBlock*) block;
@end

@interface ArticleHeaderCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UIImageView *featuredImage;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;

- (void) fillWithPost:(Post*) post;
@end

#pragma mark - Text blocks
@interface TextDisplayingCell : UITableViewCell<ArticleBlockCell, TTTAttributedLabelDelegate>
@property (nonatomic, weak) id<LinkTapDelegate> linkDelegate;
@end

@interface TextBlockCell : TextDisplayingCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textContentLabel;
@end

@interface HeaderBlockCell : TextDisplayingCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@end

@interface ListBlockCell : TextDisplayingCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@end

@interface ImageBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@end
