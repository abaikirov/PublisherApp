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
@import SDWebImage;
@import DateTools;
@import UIColor_HexString;

#pragma mark - Article header cell
@implementation ArticleHeaderCell

+ (NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

-(void)fillWithPost:(Post *)post {
   [self.featuredImage sd_setImageWithURL:post.featuredImage.featured];
   self.postTitle.text = post.postTitle;
   self.authorLabel.text = [NSString stringWithFormat:@"by %@", post.author];
   self.dateLabel.text = [post.postDate timeAgoSinceNow];
}

@end

#pragma mark - Text cell
@implementation TextDisplayingCell
+ (NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

- (void) setupAttributedLabel:(TTTAttributedLabel*) label {
   label.linkAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"e22524"], NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone)};
   label.lineSpacing = 4.0;
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

#pragma mark - Image cell
@implementation ImageBlockCell
+(NSString *)reuseIdentifier { return NSStringFromClass(self); }

- (void)fillWithBlock:(ArticleBlock *)block {
   [self.contentImage sd_setImageWithURL:[NSURL URLWithString:[block image]]];
}

@end
