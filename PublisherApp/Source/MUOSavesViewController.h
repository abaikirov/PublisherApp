//
//  SPLMSavesViewController.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 4/15/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

@import UIKit;

@interface MUOSavesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *savesTableView;

@end
