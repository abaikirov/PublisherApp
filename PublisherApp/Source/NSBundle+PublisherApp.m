//
//  NSBundle+PublisherApp.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/29/17.
//
//

#import "NSBundle+PublisherApp.h"
#import "CoreContext.h"

@implementation NSBundle (PublisherApp)

+ (NSBundle*) publisherBundle {
   return [NSBundle bundleForClass:[CoreContext class]];
}

@end
