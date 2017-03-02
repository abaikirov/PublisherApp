//
//  Post.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/12/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DCParserConfiguration;

@interface FeaturedImage : NSObject

@property (nonatomic) NSURL *featured;
@property (nonatomic) NSURL *thumb;
@property (nonatomic) NSURL *middle;

@end

@interface Post : NSObject

@property (nonatomic) NSNumber *ID;
@property (nonatomic) NSString *postTitle;
@property (nonatomic) NSString *html;
@property (nonatomic) NSString* url;
@property (nonatomic) NSDate *postDate;
@property FeaturedImage *featuredImage;

- (NSURL *)imageUrl;

//Presentation
@property (nonatomic) NSString* relativeDateString;

//Parsing
+ (DCParserConfiguration *)parserConfiguration;

@end
