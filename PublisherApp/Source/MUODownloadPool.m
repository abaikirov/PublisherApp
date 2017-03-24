//
//  MUODownloadPool.m
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/1/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import "MUODownloadPool.h"
#import "Post.h"
#import "MUOHtmlEditor.h"
#import "MUOFileCache.h"
#import "MUOPostsRequestManager.h"
@import ReactiveCocoa;
@import SDWebImage;

@interface MUODownloadPool()

@property (nonatomic, strong) MUOHtmlEditor* htmlEditor;
@property (nonatomic, strong) MUOPostsRequestManager* postsManager;
@property (nonatomic, strong) RACReplaySubject* downloadSignal;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) NSMutableArray* signalsPool;
@property (nonatomic) NSInteger imagesCount;

@end


@implementation MUODownloadPool

- (void)setEventListener:(id<DownloadPoolEventListener>)eventListener {
   _eventListener = eventListener;
   [_eventListener downloadPoolProgress:self.progress];
}

-(instancetype)init {
   self = [super init];
   if (self) {
      self.htmlEditor = [MUOHtmlEditor editor];
      self.postsManager = [MUOPostsRequestManager new];
      self.signalsPool = [NSMutableArray new];
      self.imagesCount = 0;
   }
   return self;
}

- (void)startNewDownload {
   self.imagesCount = 0;
   [self.eventListener downloadPoolStartedDownload];
}

- (void) finishDownload {
   self.progress = 0.0;
   //[[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPoolDidFinished" object:nil];
   [self.eventListener downloadPoolDidFinished];
}

#pragma mark - Downloading images
-(RACSignal *)downloadImagesForPost:(Post *)post {
   NSString* postDirectory = [[MUOFileCache sharedCache] cacheDirectoryForPostID:[post.ID integerValue]];
   
   __block NSArray* images = [self.htmlEditor getImagesFromHTML:post.html];
   
   NSMutableArray* imagesPool = [NSMutableArray new];
   for (int i = 0; i < images.count; i++) {
      NSString* imageName = [NSString stringWithFormat:@"image_%d", i];
      [imagesPool addObject:[self downloadSingleImageWithURL:[NSURL URLWithString:images[i]] localName:imageName]];
   }
   self.imagesCount += imagesPool.count;
   @weakify(self)
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      [[RACSignal concat:imagesPool] subscribeNext:^(RACTuple* tuple) {
         @strongify(self)
         UIImage* image = tuple.first;
         NSString *filePath = [postDirectory stringByAppendingPathComponent:tuple.last];
         NSData* imageData = UIImageJPEGRepresentation(image, 0.85);
         NSError* theError;
         [imageData writeToFile:filePath options:NSDataWritingAtomic error:&theError];
         
         filePath = [[NSURL fileURLWithPath:filePath] absoluteString];
         [[NSURL fileURLWithPath:filePath] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
         [post addLocalURL:filePath forRemoteImage:[tuple.second absoluteString]];
         
         self.progress += 1.0 / self.imagesCount;
         [self.eventListener downloadPoolProgress:self.progress];
      } error:^(NSError *error) {
         [subscriber sendError:error];
      } completed:^{
         [subscriber sendNext:post];
         [subscriber sendCompleted];
      }];
      return nil;
   }];
}

- (RACSignal *) downloadSingleImageWithURL:(NSURL*) url localName:(NSString*) name {
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url options:(SDWebImageDownloaderContinueInBackground | SDWebImageDownloaderUseNSURLCache) progress:nil
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                           if (finished) {
                                                              if (image && !error) {
                                                                 [subscriber sendNext:RACTuplePack(image, url, name)];
                                                                 [subscriber sendCompleted];
                                                              } else {
                                                                 //Handle error
                                                                 [subscriber sendCompleted];
                                                              }
                                                           }
                                                        }];
      return nil;
   }];
}

@end
