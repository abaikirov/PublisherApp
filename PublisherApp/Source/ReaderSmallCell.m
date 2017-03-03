//
//  SmallPostCollectionViewCell.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/25/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "ReaderSmallCell.h"
@import SDWebImage;
@import ReactiveCocoa;
@import UIColor_HexString;

@interface ReaderSmallCell()

@property (weak, nonatomic) IBOutlet UIImageView* postImageView;

@property (nonatomic, strong) UIView* bottomBorder;

@end

@implementation ReaderSmallCell

+ (NSString *)leftCellID {
   return @"LeftPostCell";
}

+(NSString *)rightCellID {
   return @"RightPostCell";
}

+ (NSString *)leftNibName {
   return @"ReaderSmallCellLeft";
}

+ (NSString *)rightNibName {
   return @"ReaderSmallCellRight";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   if (self = [super initWithCoder:aDecoder]) {
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      titleColorInactive = [[UIColor blackColor] colorWithAlphaComponent:0.5];
      titleColorActive = [UIColor colorWithHexString:@"E22524"];
      textFont = [UIFont systemFontOfSize:15.0  weight:UIFontWeightMedium];
      borderColor = [UIColor colorWithHexString:@"D8D8D8"];
   }
   return self;
}

#pragma mark - View lifecycle
-(void)awakeFromNib {
   [super awakeFromNib];
   self.titleLabel.backgroundColor = [UIColor clearColor];
   self.layer.cornerRadius = 4.0;
   self.postImageView.layer.cornerRadius = 4.0;
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
}


@end
