//
//  LargePostCollectionViewCell.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/26/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "LargePostCollectionViewCell.h"
#import "CoreContext.h"
@import SDWebImage;
@import ReactiveCocoa;

@interface LargePostCollectionViewCell(){
   UIImage* likeImageInactive;
   UIImage* likeImageActive;
}

@property (weak, nonatomic) IBOutlet UILabel* likesLabel;
@property (weak, nonatomic) IBOutlet UIImageView* likeImageView;
@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) UILabel* titleLabel;



@end

@implementation LargePostCollectionViewCell

+ (NSString *)cellID {
   return @"LargePostCell";
}

+ (NSString *)nibName {
   return @"LargePostCollectionViewCell";
}

#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   if (self = [super initWithCoder:aDecoder]) {
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      likeImageInactive = [UIImage imageNamed:@"Like-white" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
      likeImageActive = [UIImage imageNamed:@"Like-active-white" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
   }
   return self;
}

#pragma mark - View lifecycle
-(void)awakeFromNib {
   [super awakeFromNib];
   self.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
   self.titleLabel.textColor = [UIColor whiteColor];
   self.titleLabel.numberOfLines = 3;
   [self addSubview:self.titleLabel];
}

+ (CGRect)labelFrame:(Post *)post cellSize:(CGSize)cellSize {
   UIFont* textFont = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
   NSAttributedString* text = [[NSAttributedString alloc] initWithString:post.postTitle != nil ? post.postTitle : @"" attributes:@{NSFontAttributeName : textFont}];
   CGSize maxSize = CGSizeMake(cellSize.width - 30, CGFLOAT_MAX);
   CGRect size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
   CGRect frame = CGRectMake(15, cellSize.height - size.size.height - 39, maxSize.width, size.size.height);
   return frame;
}


#pragma mark - Data
- (void)fillWithPost:(Post *)post labelFrame:(CGRect)labelFrame {
   self.titleLabel.frame = labelFrame;
   self.titleLabel.text = post.postTitle;
   self.dateLabel.text = post.relativeDateString;
   
   //Setting image
   /*@weakify(self);
   [self.postImageView sd_setImageWithURL:post.featuredImage.featured completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      @strongify(self);
      self.postImageView.image = image;
      if (cacheType == SDImageCacheTypeNone) {
         self.postImageView.alpha = 0.0;
         [UIView animateWithDuration:0.3 animations:^{
            self.postImageView.alpha = 1.0;
         }];
      } else {
         self.postImageView.alpha = 1.0;
      }
   }];*/
   
   //Likes
   if ([[CoreContext sharedContext].likesManager postIsLiked:post]) {
      self.likeImageView.image = likeImageActive;
   } else {
      self.likeImageView.image = likeImageInactive;
   }
   self.likesLabel.text = post.likesString;
}

@end
