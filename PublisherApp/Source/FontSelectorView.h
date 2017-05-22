//
//  FontSelectorView.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@protocol FontSelectorViewDelegate <NSObject>

- (void) fontSizeValueDidChanged:(NSInteger) newFontSize;
- (void) fontSelectorViewDidDismiss;

@end

@interface FontSelectorView : UIView

@property (nonatomic, weak) id<FontSelectorViewDelegate> delegate;
@property NSInteger fontSize;

- (void) presentView:(BOOL) animated fromView:(UIView*) fromView;

@end
