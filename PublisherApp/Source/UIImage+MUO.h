//
//  UIImage+MUO.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/17/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MUO)

- (BOOL) isLandscape;
- (CGFloat) heightAspectRatio;
- (CGFloat) widthAspectRatio;

@end
