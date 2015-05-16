//
//  FMProcessGetFile.h
//  FastCommander
//
//  Created by Piotr Zagawa on 20.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileItem;
@class FMFileOperation;

@interface FMProcessGetFile : NSObject

@property (weak) FMFileOperation *fileOperation;

- (id)initWithFileOperation:(FMFileOperation *)fileOperation;

- (NSData *)fileItemAsData:(FMFileItem *)fileItem;

@end
