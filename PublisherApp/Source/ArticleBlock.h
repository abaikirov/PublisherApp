//
//  ArticleBlock.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/12/17.
//
//

#import <Foundation/Foundation.h>

@interface ArticleBlock : NSObject

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSDictionary* properties;
@property (nonatomic, strong) NSString* content;

@end
