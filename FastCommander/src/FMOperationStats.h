//
//  FMOperationStats.h
//  FastCommander
//
//  Created by Piotr Zagawa on 05.10.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileCopyOperation;

@interface FMOperationStats : NSObject

@property (readonly) NSString *info;

- (void)reset;

- (void)updateOnItemStart:(FMFileCopyOperation *)fileCopyOperation;
- (void)updateOnItemProgress:(FMFileCopyOperation *)fileCopyOperation;
- (void)updateOnItemFinish:(FMFileCopyOperation *)fileCopyOperation;

@end
