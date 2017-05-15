//
//  BlocksContentController.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/15/17.
//
//

#import <UIKit/UIKit.h>
#import "MUOPagingPostsController.h"

@interface BlocksContentController : UIViewController<PagingControllerPresentable>

@property (nonatomic, strong) Post* post;

@end
