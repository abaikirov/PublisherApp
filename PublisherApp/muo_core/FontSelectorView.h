//
//  FontSelectorView.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontSelectorViewDelegate <NSObject>

- (void) fontSizeValueDidChanged:(NSInteger) newFontSize;
- (void) fontSelectorViewDidDismiss;

@end

@interface FontSelectorView : UIView

@property (nonatomic, weak) id<FontSelectorViewDelegate> delegate;
@property NSInteger fontSize;

- (void) presentView:(BOOL) animated fromView:(UIView*) fromView;

@end
