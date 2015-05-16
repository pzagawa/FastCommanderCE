//
//  FMProcessTargetFile.h
//  FastCommander
//
//  Created by Piotr Zagawa on 19.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileItem;
@class FMFileCopyOperation;

@interface FMProcessTargetFile : NSObject

@property (weak) FMFileCopyOperation *fileOperation;

- (id)initWithFileOperation:(FMFileCopyOperation *)fileOperation;

- (NSString *)createAndValidatePathForItem:(FMFileItem *)fileItem;

@end
