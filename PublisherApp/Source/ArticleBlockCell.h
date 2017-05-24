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
@import youtube_ios_player_helper;

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
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textContentLabel;
@property (nonatomic, weak) id<LinkTapDelegate> linkDelegate;
@end

@interface TextBlockCell : TextDisplayingCell
@end

@interface QuoteBlockCell : TextDisplayingCell

@end

@interface HeaderBlockCell : TextDisplayingCell
@end

@interface ListBlockCell : TextDisplayingCell
@end

@interface CodeBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end

#pragma mark - Image block
@interface ImageBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@end


#pragma mark - Webview block
@interface BlockWebView : UIWebView
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) NSInteger numberOfLoads;
@end

@interface WebBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet BlockWebView *webView;
@end

#pragma mark - Video blocks
@interface YoutubeBlockCell : UITableViewCell<ArticleBlockCell>
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@end
