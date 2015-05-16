//
//  FMFileOperationProgress.h
//  FastCommander
//
//  Created by Piotr Zagawa on 06.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMFileItem;
@class FMFileOperationUserData;

@protocol FMFileOperationProgress <NSObject>

- (void)reset;
- (void)beforeStart;
- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem;
- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData;
- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData;
- (void)itemStart:(FMFileItem *)fileItem;
- (void)itemStart:(FMFileItem *)fileItem withData:(NSData *)fileData;
- (void)itemStart:(FMFileItem *)fileItem withStream:(NSInputStream *)fileStream;
- (void)itemProgress:(FMFileItem *)fileItem;
- (void)itemFinish:(FMFileItem *)fileItem;
- (void)itemError:(FMFileItem *)fileItem;
- (void)afterFinish;

@end
