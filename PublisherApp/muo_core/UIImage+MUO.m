//
//  UIImage+MUO.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/17/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "UIImage+MUO.h"

@implementation UIImage (MUO)

-(BOOL)isLandscape {
    return self.size.width > self.size.height;
}

- (CGFloat)heightAspectRatio {
    return self.size.height / self.size.width;
}

- (CGFloat)widthAspectRatio {
    return self.size.width / self.size.height;
}

@end

