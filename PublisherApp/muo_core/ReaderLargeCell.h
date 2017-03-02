//
//  LargePostCollectionViewCell.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface ReaderLargeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) UILabel* titleLabel;

+ (CGRect)labelFrame:(Post *)post cellSize:(CGSize)cellSize;
- (void)fillWithPost:(Post *)post labelFrame:(CGRect)labelFrame;

+ (NSString*) cellID;
+ (NSString*) nibName;

@end
