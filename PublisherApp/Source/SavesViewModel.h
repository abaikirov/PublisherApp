//
//  SPLMSavesViewModel.h
//  MakeUseOf
//
//  Created by AZAMAT on 5/12/15.
//  Copyright (c) 2015 Dmitry Zheshinsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavesViewModel : NSObject

@property (strong, nonatomic) NSMutableArray *saves;

- (void) loadSavesFromCache;

@end
