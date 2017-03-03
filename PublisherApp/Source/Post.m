//
//  Post.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/12/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import "Post.h"
@import DateTools;
@import DCKeyValueObjectMapping;

@implementation FeaturedImage

@end

@implementation Post


-(void)setPostDate:(NSDate *)postDate {
   _postDate = postDate;
   _relativeDateString = [_postDate shortTimeAgoSinceNow];
}

- (void)setValue:(id)value forKey:(NSString *)key {
   [super setValue:value forKey:key];
   if ([key isEqualToString:@"_postDate"]) {
      self.relativeDateString = [self.postDate shortTimeAgoSinceNow];
   }
}

+(DCParserConfiguration *)parserConfiguration {
   DCParserConfiguration *config = [DCParserConfiguration configuration];
   config.datePattern = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
   return config;
}

- (NSURL *)imageUrl {
   return self.featuredImage.thumb;
}

@end
