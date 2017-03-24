//
//  MUODownloadPool.h
//  MakeUseOf
//
//  Created by Dmitry Zheshinsky on 9/1/15.
//  Copyright (c) 2015 MakeUseOf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import ReactiveCocoa;

@class Post;

@protocol DownloadPoolEventListener <NSObject>

- (void) downloadPoolStartedDownload;
- (void) downloadPoolProgress:(CGFloat) progress;
- (void) downloadPoolDidFinished;

@end


@interface MUODownloadPool : NSObject

@property (nonatomic, weak) id<DownloadPoolEventListener> eventListener;

- (void) startNewDownload;
- (void) finishDownload;
- (RACSignal *) downloadImagesForPost:(Post *) post;

@end
