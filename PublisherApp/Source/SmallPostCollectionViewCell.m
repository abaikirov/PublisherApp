//
//  SmallPostCollectionViewCell.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/25/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "SmallPostCollectionViewCell.h"
@import SDWebImage;
#import "CoreContext.h"
@import UIColor_HexString;

@interface SmallPostCollectionViewCell() {
   UIColor* titleColorInactive;
   UIColor* titleColorActive;
   UIFont* textFont;
   UIColor* borderColor;
   UIImage* likeImageActive;
   UIImage* likeImageInactive;
}

@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* likesCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView* likeImageView;
@property BOOL touchesMoved;

@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (nonatomic, strong) UIView* bottomBorder;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@end

@implementation SmallPostCollectionViewCell

#pragma mark - Reuse

+ (NSString *)cellID {
   return @"SmallPostCell";
}

+ (NSString *)nibName {
   return @"SmallPostCollectionViewCell";
}

#pragma mark - Init
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   if (self = [super initWithCoder:aDecoder]) {
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      titleColorInactive = [[UIColor blackColor] colorWithAlphaComponent:0.5];
      titleColorActive = [UIColor colorWithHexString:@"E22524"];
      textFont = [UIFont systemFontOfSize:15.0  weight:UIFontWeightMedium];
      borderColor = [UIColor colorWithHexString:@"D8D8D8"];
      likeImageInactive = [UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
      likeImageActive = [UIImage imageNamed:@"Like-active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
   }
   return self;
}


#pragma mark - View lifecycle
-(void)awakeFromNib {
   [super awakeFromNib];
   self.titleLabel.backgroundColor = [UIColor clearColor];
   self.layer.cornerRadius = 4.0;
   self.postImageView.layer.cornerRadius = 4.0;
   self.touchesMoved = NO;
}

- (void)didMoveToSuperview {
   [super didMoveToSuperview];
   self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.7, self.frame.size.width + 3, 0.5)];
   self.bottomBorder.backgroundColor = borderColor;
   [self addSubview:self.bottomBorder];
   [self addSubview:self.titleLabel];
   self.titleLabel.font = textFont;
   self.titleLabel.numberOfLines = 4;
   self.titleLabel.textColor = [UIColor colorWithHexString:@"432D2D"];
}

- (void)markAsNew {
   self.dateLabel.textColor = titleColorActive;
}

- (void)prepareForReuse {
   [super prepareForReuse];
   self.dateLabel.textColor = titleColorInactive;
   self.backgroundColor = [UIColor whiteColor];
}


+(CGRect)labelHeightForPost:(Post *)post left:(BOOL)left imageSize:(CGSize)imageSize {
   CGFloat leftOffset = 0;
   if (left) {
      leftOffset = 16;
   } else {
      leftOffset = 10;
   }
   UIFont* textFont = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
   NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:post.postTitle attributes:@{NSFontAttributeName : textFont}];
   CGFloat width = ceil(imageSize.width);
   CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
   CGRect size = [attributedString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
   CGFloat height = ceil(MIN(size.size.height, 72));
   CGRect frame = CGRectMake(leftOffset, imageSize.height + 16, maxSize.width, height);
   return frame;
}

- (void)setAlignment:(CellAlignment)alignment {
   if (alignment == CellAlignmentLeft) {
      self.leadingConstraint.constant = 16;
      self.trailingConstraint.constant = 10;
   } else {
      self.leadingConstraint.constant = 10;
      self.trailingConstraint.constant = 16;
   }
}

#pragma mark - Data
- (void)fillWithPost:(Post *)post labelFrame:(CGRect)labelFrame {
   self.titleLabel.frame = labelFrame;
   self.titleLabel.text = post.postTitle;
   self.dateLabel.text = post.relativeDateString;
   
   //Setting image
   @weakify(self);
   [self.postImageView sd_setImageWithURL:post.featuredImage.middle completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
   }];
   
   //Likes
   if ([[CoreContext sharedContext].likesManager postIsLiked:post]) {
      self.likeImageView.image = likeImageActive;
      self.likesCountLabel.textColor = titleColorActive;
   } else {
      self.likesCountLabel.textColor = titleColorInactive;
      self.likeImageView.image = likeImageInactive;
   }
   self.likesCountLabel.text = post.likesString;
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   self.backgroundColor = [UIColor colorWithHexString:@"e8eaed"];
   [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   self.touchesMoved = YES;
   [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   [super touchesCancelled:touches withEvent:event];
   self.backgroundColor = [UIColor whiteColor];
   self.touchesMoved = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   [super touchesEnded:touches withEvent:event];
   if (self.touchesMoved) {
      self.backgroundColor = [UIColor whiteColor];
   }
   self.touchesMoved = NO;
}


@end
