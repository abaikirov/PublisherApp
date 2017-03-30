//
//  MUONavigationController.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/24/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "MUONavigationController.h"

@interface MUONavigationController ()

@end

@implementation MUONavigationController

- (void)viewDidLoad {
   [super viewDidLoad];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
   return self.visibleViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate {
   return self.visibleViewController.shouldAutorotate;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
   return self.visibleViewController.preferredStatusBarStyle;
}


@end
