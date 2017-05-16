//
//  BlocksDataProvider.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import <Foundation/Foundation.h>
@import UIKit;
@class ArticleBlock;

@interface BlocksDataProvider : NSObject

- (instancetype) initWithTableView:(UITableView*) tableView blocks:(NSArray*) blocks;

- (ArticleBlock*) blockForIndexPath:(NSIndexPath*) indexPath;
- (CGFloat) heightForBlock:(ArticleBlock*) block;
- (NSInteger) numberOfRows;
- (Class) cellClassForBlock:(ArticleBlock*) block;

@end

