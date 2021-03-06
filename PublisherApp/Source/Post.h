//
//  Post.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 1/12/17.
//  Copyright © 2017 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArticleBlock;
@class DCParserConfiguration;
@class MUOSavedPost;

@interface FeaturedImage : NSObject
@property (nonatomic) NSURL *featured;
@property (nonatomic) NSURL *middle;
@end

@interface PostCategory : NSObject
@property (nonatomic, strong) NSNumber* id;
@property (nonatomic, strong) NSString* title;
@end


#pragma mark - The Post
@interface Post : NSObject

@property (nonatomic) NSNumber *ID;
@property (nonatomic) NSNumber* channelId;
@property (nonatomic) NSString *postTitle;
@property (nonatomic) NSString *html;
@property (nonatomic) NSString* url;
@property (nonatomic) NSString* author;
@property (nonatomic) NSDate *postDate;
@property FeaturedImage *featuredImage;
@property (nonatomic) NSNumber *likesCount;
@property (nonatomic, strong) NSArray* categories;
- (NSURL *)imageUrl;

//Presentation
@property (nonatomic) NSString* relativeDateString;
@property (nonatomic) NSString* likesString;
- (NSString*) longDate;

//Blocks
@property (nonatomic, strong) NSArray<ArticleBlock*>* blocks;
- (void) prerenderBlocksWithIndexes:(NSArray*) visibleIndexes updateBlock:(void(^)()) updateBlock;
- (NSArray*) imagesFromBlocks;
- (NSArray*) youtubeBlocksIDs;

//Parsing
+ (DCParserConfiguration *)parserConfiguration;

//Bookmarks related code
+ (instancetype) postWithSavedPost:(MUOSavedPost*) savedPost;

//This section links remote URLs with local URLs
- (void) addLocalURL:(NSString*)localUrl forRemoteImage:(NSString*) imageUrl;
- (void) replaceRemoteUrlsWithLocal;
- (void) clearLocalURLs;

/**
 Gets the post for saving to Realm
 **/
- (MUOSavedPost*) postToSave:(BOOL) isBookmarked;
- (void) fillWithSavedPost:(MUOSavedPost *) post;

@end
