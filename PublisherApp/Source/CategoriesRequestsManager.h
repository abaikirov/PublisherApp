//
//  CategoriesRequestsManager.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 4/3/17.
//
//

#import <Foundation/Foundation.h>
@import ReactiveCocoa;

@interface CategoriesRequestsManager : NSObject

- (RACSignal*) fetchCategories;

@end
