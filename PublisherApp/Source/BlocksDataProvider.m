//
//  BlocksDataProvider.m
//  Pods
//
//  Created by Dmitry Zheshinsky on 5/16/17.
//
//

#import "BlocksDataProvider.h"
#import "ArticleBlock.h"
#import "ArticleBlockCell.h"

@interface BlocksDataProvider()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray<ArticleBlock*>* blocks;
@property (nonatomic, strong) NSArray<ArticleBlock*>* availableBlocks;
@end

@implementation BlocksDataProvider
- (NSArray*) availableBlocksType {
   return @[kTextBlock, kImageBlock, kHeaderBlock, kListBlock, kYoutubeBlock, kCodeBlock];
}

#pragma mark - Initialization
-(instancetype)initWithTableView:(UITableView *)tableView blocks:(NSArray *)blocks {
   self = [super init];
   if (self) {
      self.tableView = tableView;
      self.blocks = blocks;
      [self generateAvailableBlocks];
   }
   return self;
}


#pragma mark - Blocks provider
- (void) generateAvailableBlocks {
   NSMutableArray* availableBlocks = [NSMutableArray new];
   for (ArticleBlock* block in self.blocks) {
      if ([[self availableBlocksType] containsObject:block.type]) {
         [availableBlocks addObject:block];
      }
   }
   self.availableBlocks = availableBlocks;
}

#pragma mark - Table view provider
- (ArticleBlock*) blockForIndexPath:(NSIndexPath*) indexPath {
   return self.availableBlocks[indexPath.row - 1];
}

- (CGFloat)heightForBlock:(ArticleBlock *)block {
   if ([block.type isEqualToString:kImageBlock]) {
      return [block blockHeight];
   }
   return UITableViewAutomaticDimension;
}

- (NSInteger) numberOfRows {       //Returns only blocks that are currently available to be displayed
   return [self.availableBlocks count];
}

- (Class)cellClassForBlock:(ArticleBlock *)block {
   NSDictionary* classes = @{ kTextBlock : [TextBlockCell class], kImageBlock : [ImageBlockCell class], kHeaderBlock : [HeaderBlockCell class],
                              kListBlock : [ListBlockCell class], kYoutubeBlock : [YoutubeBlockCell class], kCodeBlock : [CodeBlockCell class]};
   return classes[block.type];
}

@end
