//
//  FontSelectorView.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/27/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "FontSelectorView.h"

static const CGFloat topOffset = 50;
static const float sliderStep = 100.0f;

@interface FontSelectorView()

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UISlider* slider;

@end

@implementation FontSelectorView

#pragma mark - Initialisation
- (instancetype)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
      self.backgroundView = [[UIView alloc] initWithFrame:frame];
      self.backgroundView.backgroundColor = [UIColor clearColor];
      [self addSubview:self.backgroundView];
   }
   return self;
}


#pragma mark - Labels
- (void) setupLabels {
   UILabel* leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topOffset, 50, 50)];
   leftLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightRegular];
   leftLabel.textColor = [UIColor whiteColor];
   leftLabel.textAlignment = NSTextAlignmentCenter;
   leftLabel.text = @"A";
   [self addSubview:leftLabel];
   
   UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 50, topOffset, 50, 40)];
   rightLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
   rightLabel.textColor = [UIColor whiteColor];
   rightLabel.textAlignment = NSTextAlignmentCenter;
   rightLabel.text = @"A";
   [self addSubview:rightLabel];
}


#pragma mark - Slider
- (void) setupSlider {
   UIView* sliderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, topOffset, screen_width, 40)];
   sliderBackgroundView.backgroundColor = [UIColor clearColor];
   [self addSubview:sliderBackgroundView];
   
   self.slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 5, screen_width-100, 30)];
   self.slider.minimumValue = -200;
   self.slider.maximumValue = 200;
   self.slider.continuous = YES;
   self.slider.minimumTrackTintColor = [UIColor whiteColor];
   self.slider.maximumTrackTintColor = [UIColor whiteColor];
   NSBundle* bundle = [NSBundle bundleForClass:[self class]];
   [self.slider setThumbImage:[UIImage imageNamed:@"Knob" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
   [sliderBackgroundView addSubview:self.slider];
   
   [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
   [self.slider setValue:self.fontSize * sliderStep animated:false];
}

- (void) sliderValueChanged:(UISlider *) slider {
   float step = 10.0;
   float value = roundf(slider.value / step) * step;
   [slider setValue:value animated:YES];
   
   NSArray* fontRanges = @[@(-200), @(-190), @(-110), @(-100), @(-90), @(-10), @(0), @(10), @(90), @(100), @(110), @(190), @(200)];
   if ([fontRanges containsObject:[NSNumber numberWithFloat:slider.value]]) {
      NSInteger newFontSize = slider.value / 100;
      if(newFontSize != self.fontSize) {
         self.fontSize = newFontSize;
         [self.delegate fontSizeValueDidChanged:newFontSize];
      }
   }
}

#pragma mark - Presentation
- (void) presentView:(BOOL) animated fromView:(UIView*) fromView {
   [fromView addSubview:self];
   [fromView bringSubviewToFront:self];
   [UIView animateWithDuration:0.3 animations:^{
      self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
      [self setupSlider];
      [self setupLabels];
   }];
}

- (void) dismiss {
   [UIView animateWithDuration:0.3 animations:^{
      self.backgroundView.backgroundColor = [UIColor clearColor];
      self.alpha = 0.0;
   } completion:^(BOOL finished) {
      [self.delegate fontSelectorViewDidDismiss];
      [self removeFromSuperview];
   }];
}


#pragma mark - Touches
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
   CGRect sliderRect = CGRectMake(0, 0, screen_width, screen_width * 0.7);
   if (CGRectContainsPoint(sliderRect, point)) {
      return self.slider;
   }
   [self dismiss];
   return nil;
}
@end
