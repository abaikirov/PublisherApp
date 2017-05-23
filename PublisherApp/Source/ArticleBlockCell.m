//
//  ArticleBlockCell.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import "ArticleBlockCell.h"
#import "Post.h"
#import "UIFont+Additions.h"
#import "ReaderSettings.h"
@import SDWebImage;
@import DateTools;
@import UIColor_HexString;

#pragma mark - Article header cell
@implementation ArticleHeaderCell

+ (NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

+ (CGFloat) smallLabelFontSize {
   NSArray* sizes = @[@(12), @(14), @(15), @(16), @(18)];
   FontSize fontSize = [ReaderSettings sharedSettings].preferredFontSize;
   return [sizes[fontSize + 2] integerValue];
}

+ (CGFloat) headerFontSize {
   NSArray* sizes = @[@(22), @(24), @(25), @(26), @(28)];
   FontSize fontSize = [ReaderSettings sharedSettings].preferredFontSize;
   return [sizes[fontSize + 2] integerValue];
}

-(void)fillWithPost:(Post *)post {
   [self.featuredImage sd_setImageWithURL:post.featuredImage.featured];
   self.postTitle.text = post.postTitle;
   self.authorLabel.text = [NSString stringWithFormat:@"by %@", post.author];
   self.dateLabel.text = [post.postDate timeAgoSinceNow];
   
   self.dateLabel.font = [UIFont fontWithName:self.dateLabel.font.fontName size:[ArticleHeaderCell smallLabelFontSize]];
   self.authorLabel.font = [UIFont fontWithName:self.authorLabel.font.fontName size:[ArticleHeaderCell smallLabelFontSize]];
   self.postTitle.font = [UIFont fontWithName:self.postTitle.font.fontName size:[ArticleHeaderCell headerFontSize]];
}

@end

#pragma mark - Text cell
@implementation TextDisplayingCell
+ (NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

- (void) setupAttributedLabel:(TTTAttributedLabel*) label {
   label.linkAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"e22524"], NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone)};
   label.lineSpacing = 8.0;
   label.delegate = self;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
   if ([self.linkDelegate respondsToSelector:@selector(linkTapped:)]) {
      [self.linkDelegate linkTapped:url];
   }
}

@end

@implementation TextBlockCell
- (void)awakeFromNib {
   [super awakeFromNib];
   [self setupAttributedLabel:self.textContentLabel];
}

- (void)fillWithBlock:(ArticleBlock *)block {
   self.textContentLabel.text = [block prerenderedText];
}
@end


#pragma mark - Header
@implementation HeaderBlockCell
- (void)awakeFromNib {
   [super awakeFromNib];
   [self setupAttributedLabel:self.contentLabel];
}


- (void)fillWithBlock:(ArticleBlock *)block {
   self.contentLabel.text = [block prerenderedText];
}
@end

#pragma mark - List
@implementation ListBlockCell
- (void)awakeFromNib {
   [super awakeFromNib];
   [self setupAttributedLabel:self.contentLabel];
}

- (void)fillWithBlock:(ArticleBlock *)block {
   self.contentLabel.text = [block prerenderedText];
}

@end


#pragma mark - Code
@implementation CodeBlockCell

- (void)fillWithBlock:(ArticleBlock *)block {
   NSArray* sizes = @[@(12), @(14), @(15), @(16), @(18)];
   FontSize fontSize = [ReaderSettings sharedSettings].preferredFontSize;
   self.contentLabel.text = block.content;
   self.contentLabel.font = [UIFont fontWithName:self.contentLabel.font.fontName size:[sizes[fontSize + 2] integerValue]];
}
@end

#pragma mark - Image cell
@implementation ImageBlockCell
+(NSString *)reuseIdentifier { return NSStringFromClass(self); }

- (void)fillWithBlock:(ArticleBlock *)block {
   [self.contentImage sd_setImageWithURL:[NSURL URLWithString:[block image]]];
}
@end

#pragma mark - Youtube cell
@implementation YoutubeBlockCell
+(NSString *)reuseIdentifier { return NSStringFromClass(self); }

- (void)fillWithBlock:(ArticleBlock *)block {
   NSDictionary* playerVars = @{ @"controls" : @(2), @"showinfo" : @(0), @"playsinline" : @(1), @"rel" : @(0)};
   [self.playerView loadWithVideoId:@"P14O3Ob_B7Q" playerVars:playerVars];
}

@end
