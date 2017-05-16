//
//  ArticleBlockCell.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import "ArticleBlockCell.h"
#import "Post.h"
@import SDWebImage;
@import DateTools;

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
@implementation TextBlockCell

+(NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

- (void)fillWithBlock:(ArticleBlock *)block {
   self.textBlockLabel.text = block.content;
}
@end

#pragma mark - Image cell
@implementation ImageBlockCell
+(NSString *)reuseIdentifier {
   return NSStringFromClass(self);
}

- (void)fillWithBlock:(ArticleBlock *)block {
   NSString* imageURL = block.properties[@"url"];
   [self.contentImage sd_setImageWithURL:[NSURL URLWithString:imageURL]];
}

@end
