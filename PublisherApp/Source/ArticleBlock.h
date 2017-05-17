//
//  ArticleBlock.h
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import <Foundation/Foundation.h>

static NSString* kTextBlock = @"text";
static NSString* kImageBlock = @"image";

@protocol ArticleBlockExtensions <NSObject>
@optional
- (CGFloat) blockHeight; //Used for images
- (NSAttributedString*) prerenderedText;
@end


@interface ArticleBlock : NSObject<ArticleBlockExtensions>

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSDictionary* properties;
@property (nonatomic, strong) NSString* content;


@end
