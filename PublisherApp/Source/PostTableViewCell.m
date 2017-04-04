//
//  PostTableViewCell.m
//  PublisherApp
//
//  Created by Dmitry Zheshinsky on 3/28/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

@import SDWebImage;
#import "PostTableViewCell.h"
#import "MUOSavedPost.h"
#import "Post.h"

@interface PostTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel* postTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* categoryLabel;


@end

@implementation PostTableViewCell

+ (NSString *)cellID {
   return @"PostCell";
}

+ (NSBundle*) bundle {
   return [NSBundle bundleForClass:[self class]];
}


+ (CGFloat)cellHeight {
   return 94.0f;
}

- (void)awakeFromNib {
   [super awakeFromNib];
   self.postImageView.layer.masksToBounds = YES;
   self.postImageView.layer.cornerRadius = 6.0;
   self.layer.shouldRasterize = YES;
   self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   [super setSelected:selected animated:animated];
   
   // Configure the view for the selected state
}

- (void)fillWithPost:(Post *)post {
   self.postTitleLabel.text = post.postTitle;
   self.dateLabel.text = [post longDate];
   [self.postImageView sd_setImageWithURL:post.featuredImage.middle];
   NSMutableString* categoriesText = [NSMutableString new];
   for (PostCategory* category in post.categories) {
      [categoriesText appendString:[category.title uppercaseString]];
      if (category != [post.categories lastObject]) {
         [categoriesText appendString:@", "];
      }
   }
   self.categoryLabel.text = categoriesText;
}

- (void)fillWithSavedPost:(MUOSavedPost *)post {
   self.postTitleLabel.text = post.title;
   self.dateLabel.text = [post postDate];
   self.categoryLabel.text = [post.primaryCategory uppercaseString];
   [self.postImageView sd_setImageWithURL:[NSURL URLWithString:post.imageUrl]];
}

@end
