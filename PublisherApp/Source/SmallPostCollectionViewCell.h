//
//  SmallPostCollectionViewCell.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostRepresentable.h"

typedef enum {
   CellAlignmentLeft,
   CellAlignmentRight
} CellAlignment;

@interface SmallPostCollectionViewCell : UICollectionViewCell<PostRepresentable>

@property (nonatomic, strong) UILabel* titleLabel;

- (void) markAsNew;
- (void) setAlignment:(CellAlignment) alignment;

@end
