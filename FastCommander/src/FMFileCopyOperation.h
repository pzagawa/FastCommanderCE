//
//  FMFileCopyOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 31.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileCopyOperation : FMFileOperation

typedef enum
{
    FMFileCopyOperationMode_COPY = 1,
    FMFileCopyOperationMode_MOVE = 2,

} FMFileCopyOperationMode;

@property (readonly) FMFileCopyOperationMode mode;

@property (readonly) long fileIndex;
@property long long fileProgressSize;
@property (readonly) long long totalProgressSize;

@property (readonly) int fileProgressPercentBySize;
@property (readonly) int totalProgressPercentBySize;

@property (readonly) long fileProcessingTimeMiliseconds;
@property (readonly) long long fileSpeedBytesPerSecond;

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

- (void)removeIncompleteFile:(FMFileItem *)fileItem inPath:(NSString *)targetFilePath;

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target withMode:(FMFileCopyOperationMode)mode;

@end
