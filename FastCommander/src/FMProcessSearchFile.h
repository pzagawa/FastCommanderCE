//
//  FMProcessSearchFile.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileItem;
@class FMFileSearchOperation;

@interface FMProcessSearchFile : NSObject

@property (weak) FMFileSearchOperation *fileOperation;

@property BOOL matchFound;
@property NSUInteger matchPosition;

- (id)initWithFileOperation:(FMFileSearchOperation *)fileOperation andText:(NSString *)text;

- (void)searchTextInFileItem:(FMFileItem *)fileItem;

@end
