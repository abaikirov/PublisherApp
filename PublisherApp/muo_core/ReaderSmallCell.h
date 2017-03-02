//
//  SmallPostCollectionViewCell.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface ReaderSmallCell : UICollectionViewCell {
   UIColor* titleColorInactive;
   UIColor* titleColorActive;
   UIFont* textFont;
   UIColor* borderColor;
}


@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) UILabel* titleLabel;

+ (CGRect) labelHeightForPost:(Post *)post left:(BOOL)left imageSize:(CGSize)imageSize;
- (void) fillWithPost:(Post *)post labelFrame:(CGRect)labelFrame;

+ (NSString*) leftCellID;
+ (NSString*) rightCellID;

+ (NSString*) leftNibName;
+ (NSString*) rightNibName;

@end
