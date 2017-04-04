//
//  CategoryPostsViewController.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 4/4/17.
//
//

#import <UIKit/UIKit.h>

@class PostCategory;
@interface CategoryPostsViewController : UIViewController

@property (nonatomic, strong) PostCategory* filteredCategory;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
