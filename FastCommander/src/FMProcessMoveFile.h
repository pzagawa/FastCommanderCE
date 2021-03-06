//
//  FMProcessMoveFile.h
//  FastCommander
//
//  Created by Piotr Zagawa on 30.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileItem;
@class FMFileCopyOperation;

@interface FMProcessMoveFile : NSObject

@property (weak) FMFileCopyOperation *fileOperation;

- (id)initWithFileOperation:(FMFileCopyOperation *)fileOperation;

- (void)moveFileItem:(FMFileItem *)fileItem toPath:(NSString *)targetFilePath;

@end
