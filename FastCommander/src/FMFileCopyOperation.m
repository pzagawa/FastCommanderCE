//
//  FMFileCopyOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 31.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <mach/mach_time.h>
#import "FMFileCopyOperation.h"
#import "FMFileAnalyzingOperation.h"
#import "FMFileItem.h"
#import "FMFileOperationProgress.h"
#import "FMProcessCopyFile.h"
#import "FMProcessMoveFile.h"
#import "FMProcessTargetFile.h"
#import "FMPanelListProvider.h"
#import "FMOperationCopyWindow.h"

@implementation FMFileCopyOperation
{
    uint64_t _fileProcessStartTime;

    FMProcessTargetFile *_processTargetFile;
    FMProcessCopyFile *_processCopyFile;
    FMProcessMoveFile *_processMoveFile;
    
    long long _currentFileSize;
    long long _totalProgressSize;
    
    FMFileItem *_targetFileItem;
    
    NSMutableSet *_directoriesToRemoveAfterMove;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
        self->_processTargetFile = [[FMProcessTargetFile alloc] initWithFileOperation:self];
        self->_processCopyFile = [[FMProcessCopyFile alloc] initWithFileOperation:self];
        self->_processMoveFile = [[FMProcessMoveFile alloc] initWithFileOperation:self];

        self->_directoriesToRemoveAfterMove = [[NSMutableSet alloc] initWithCapacity:100];
    }
    
    return self;
}

- (void)run:(OnOperationFinish)onFinish
{
    [FMOperationCopyWindow showSheet:self];

    [super run:onFinish];
}

- (void)runOnNewThread
{
    //create target directory file item for checks
    self->_targetFileItem = [self.targetProvider fileNameToFileItem:self.targetProvider.currentPath];

    //process file items
    [self processFileItems];
}

- (void)processFileItemsStart
{
    self->_fileIndex = 1;
    self->_totalProgressSize = 0;
    self->_fileProcessStartTime = 0;
    
    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //first file item if only one to process
    FMFileItem *firstFileItem = nil;
    
    //get the only one file item to process
    if (self.filesTotalCountIsOne)
    {
        firstFileItem = [self.fileItems objectAtIndex:0];
    }
    
    //update UI before proceed if ONE item to process only
    if (firstFileItem != nil)
    {
        //create target file path
        firstFileItem.targetFilePath = [self.sourceProvider getTargetFileName:firstFileItem withTargetPath:self.targetProvider.currentPath];
        
        //SYNC start file operation dispatch to avoid bugs
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemStart:firstFileItem];
        });
    }
    
    //check if paused before explicit user start
    if (self.isPaused)
    {
        [self waitOnResume];
    }
    
    //update UI before proceed if ONE item to process only
    if (firstFileItem != nil)
    {
        //SYNC update fileItem from UI
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate updateFileItemBeforeStart:firstFileItem];
        });
    }
}

- (void)processFileItemsFinish
{
    //postprocess in MOVE mode
    if (self.mode == FMFileCopyOperationMode_MOVE)
    {
        [self removeEmptySourceDirectories];
    }
    
    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
    
    //pause before close
    if (self.isCanceled == NO)
    {
        [NSThread sleepForTimeInterval:0.5];
    }
}

- (void)processFileItems
{
    [self processFileItemsStart];
    
    //check if operation canceled
    if (self.isCanceled == NO)
    {
        for (FMFileItem *fileItem in self.fileItems)
        {
            self.isDataChanged = YES;

            BOOL isRetry = NO;
            
            while (YES)
            {
                [self resetFileItemStats:fileItem isRetry:isRetry];

                //SYNC start file operation dispatch to avoid bugs
                dispatch_sync(dispatch_get_main_queue(), ^
                {
                    [self.progressDelegate itemStart:fileItem];
                });
                
                [self processFileItem:fileItem];

                [self updateFileItemStats:fileItem];

                [self processFileItemResult:fileItem];
                
                //check if operation paused
                if (self.isPaused)
                {
                    [self waitOnResume];
                }
                
                //SYNC finish item operation
                dispatch_sync(dispatch_get_main_queue(), ^
                {
                    [self.progressDelegate itemFinish:fileItem];
                });

                //check if fileItem needs to be processed again
                isRetry = [self checkIfRetryProcessFileItem:fileItem];
                
                [self resetUserActionRequests];

                //check if operation canceled
                if (self.isCanceled)
                {
                    break;
                }
                
                //exit retry loop on default
                if (isRetry == NO)
                {
                    break;
                }
            }

            //check if operation canceled
            if (self.isCanceled)
            {
                break;
            }
        }        
    }

    [self processFileItemsFinish];
}

- (void)resetFileItemStats:(FMFileItem *)fileItem isRetry:(BOOL)isRetry
{
    self->_fileProgressSize = 0;
    self->_currentFileSize = fileItem.fileSize;
    
    if (isRetry)
    {
        if (fileItem.isDirectory == NO)
        {
            self->_fileIndex--;
            self->_fileProgressSize = 0;
            self->_totalProgressSize -= fileItem.fileSize;
        }
    }
}

- (void)updateFileItemStats:(FMFileItem *)fileItem
{
    if (fileItem.isDirectory == NO)
    {
        self->_fileIndex++;
        self->_fileProgressSize = 0;
        self->_totalProgressSize += fileItem.fileSize;
    }
}

- (void)processFileItemResult:(FMFileItem *)fileItem
{
    //status for error processing
    [self.userAction resetActionType];
    
    //process status on error
    if (fileItem.isError)
    {
        //check user action type if apply to all checked
        [self.userAction updateActionTypeForStatus:fileItem.status];
        
        //pause on error
        if (self.userAction.actionType == FMOperationUserActionType_NONE)
        {
            [self requestPause];
            
            //SYNC finish item operation
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                [self.progressDelegate itemError:fileItem];
            });
        }
    }
}

- (BOOL)checkIfRetryProcessFileItem:(FMFileItem *)fileItem
{
    //check if operation OVERWRITE
    if (self.isOverwriteRequest || self.userAction.actionType == FMOperationUserActionType_OVERWRITE)
    {
        fileItem.userActionType = FMOperationUserActionType_OVERWRITE;
        
        [fileItem setStatus:FMFileItemStatus_TODO];
        
        //try again
        return YES;
    }
    
    //check if operation RETRY
    if (self.isRetryRequest || self.userAction.actionType == FMOperationUserActionType_RETRY)
    {
        fileItem.userActionType = FMOperationUserActionType_SKIP;
        
        [fileItem setStatus:FMFileItemStatus_TODO];

        //try again
        return YES;
    }
    
    //check if operation SKIP
    if (self.isSkipRequest || self.userAction.actionType == FMOperationUserActionType_SKIP)
    {
        //try again
        return NO;
    }
    
    return NO;
}

- (void)processFileItem:(FMFileItem *)fileItem
{
    self->_fileProcessStartTime = mach_absolute_time();

    //create target path
    NSString *targetPath = [self->_processTargetFile createAndValidatePathForItem:fileItem];

    //process directory
    if (fileItem.isDirectory == YES)
    {
        //update directories cache
        [self->_directoriesToRemoveAfterMove addObject:fileItem.filePath];
        
        return;
    }

    //process file
    if (fileItem.isDirectory == NO)
    {
        if (targetPath == nil)
        {
            return;
        }

        //check User Action type
        if (fileItem.userActionType == FMOperationUserActionType_OVERWRITE)
        {
            [self.targetProvider removeFile:targetPath];
        }
        
        //COPY MODE
        if (self.mode == FMFileCopyOperationMode_COPY)
        {
            [self->_processCopyFile copyFileItem:fileItem toPath:targetPath];
        }

        //MOVE MODE
        if (self.mode == FMFileCopyOperationMode_MOVE)
        {
            //check if source and target are on the same volume
            if ([fileItem isTheSameVolume:self->_targetFileItem])
            {
                //the same volume - move at once
                [self->_processMoveFile moveFileItem:fileItem toPath:targetPath];
            }
            else
            {
                //different volumes - copy with progress
                [self->_processCopyFile copyFileItem:fileItem toPath:targetPath];
                
                //check if target file size equals source
                FMFileItem *targetFileItem = [FMFileItem fromFilePath:targetPath];
                
                if (targetFileItem.fileSize != 0)
                {
                    if (targetFileItem.fileSize == fileItem.fileSize)
                    {
                        //remove source file after copy
                        if ([self.sourceProvider removeFile:fileItem.filePath] == NO)
                        {
                            [fileItem setStatus:FMFileItemStatus_SOURCE_REMOVE_ERROR];
                        }
                    }
                }
            }

            //update directories cache
            if (fileItem.isDone)
            {
                NSString *targetDirectory = [fileItem.filePath stringByDeletingLastPathComponent];
            
                [self->_directoriesToRemoveAfterMove addObject:targetDirectory];
            }
        }

        return;
    }
}

- (long)fileProcessingTimeMiliseconds
{
    return [self milisFromKernelTime:(mach_absolute_time() - _fileProcessStartTime)];
}

- (long long)fileSpeedBytesPerSecond
{
    long bytesProgress = self.fileProgressSize;
    
    double milisFromStart = self.fileProcessingTimeMiliseconds / 1000.0;
    
    long long value = 0;
    
    if (milisFromStart > 0)
    {
        value = (bytesProgress / milisFromStart);
    }
    
    return value;
}

- (void)removeEmptySourceDirectories
{
    for (NSString *path in self->_directoriesToRemoveAfterMove)
    {
        //skip source path panel directory
        if ([path isEqualToString:self.sourceProvider.currentPath])
        {
            continue;
        }

        //remove other directories
        if ([self.sourceProvider directoryExists:path])
        {
            int filesCount = [self.sourceProvider filesCountForPath:path];
            
            if (filesCount == 0)
            {
                [self.sourceProvider removeDirectory:path];
            }
        }
    }
}

- (void)removeIncompleteFile:(FMFileItem *)fileItem inPath:(NSString *)targetFilePath
{
    if (targetFilePath != nil)
    {
        //skip if target exists
        if (fileItem.isTargetExists)
        {
            return;
        }
        
        //delete if canceled
        if (fileItem.isCanceled)
        {
            [self.targetProvider removeFile:targetFilePath];
            return;
        }
        
        //delete for selected errors
        BOOL removeFileOnError = NO;
        
        if (fileItem.status == FMFileItemStatus_READ_ERROR)
        {
            removeFileOnError = YES;
        }
        
        if (fileItem.status == FMFileItemStatus_WRITE_ERROR)
        {
            removeFileOnError = YES;
        }
        
        if (removeFileOnError)
        {
            [self.targetProvider removeFile:targetFilePath];
            return;
        }
    }
}

- (long long)totalProgressSize
{
    return self->_totalProgressSize + self->_fileProgressSize;
}

- (int)totalProgressPercentBySize
{
    long long totalSize = self.filesTotalSize.longLongValue;
    
    if (totalSize == 0)
        return 0;
    
    return (int)((self.totalProgressSize * 100) / totalSize);
}

- (int)fileProgressPercentBySize
{
    long long fileSize = self->_currentFileSize;
    
    if (fileSize == 0)
        return 0;
    
    return (int)((self.fileProgressSize * 100) / fileSize);
}

- (void)finishOnUiThread
{
    [FMOperationCopyWindow close];

    if (self.isDataChanged)
    {
        if (self.mode == FMFileCopyOperationMode_COPY)
        {
            [self reloadTargetPanel:^(FMReloadData *data){}];
            return;
        }
        
        if (self.mode == FMFileCopyOperationMode_MOVE)
        {
            [self reloadBothPanels];
            return;
        }
    }
}

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target withMode:(FMFileCopyOperationMode)mode
{
    //copy operation
    FMFileCopyOperation *copyOperation = [[FMFileCopyOperation alloc] initWithProvider:source andTarget:target];

    copyOperation->_mode = mode;
    
    //block after finishing copying
    OnOperationFinish onCopyingFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (copyOperation.isCanceled == NO)
        {
        }
    };

    //analyze source operation
    FMFileAnalyzingOperation *analyzingOperation = [[FMFileAnalyzingOperation alloc] initWithProvider:source andTarget:nil];
    
    //block after finishing analyzing
    OnOperationFinish onAnalyzingFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (analyzingOperation.isCanceled == NO)
        {
            //retain parent reference to child object
            copyOperation.fileItems = analyzingOperation.fileItems;

            //release parent strong reference
            analyzingOperation.fileItems = nil;
            
            //continue with new operation
            [copyOperation run:onCopyingFinish];
        }
    };

    //begin with analyzing operation
    [analyzingOperation run:onAnalyzingFinish];
}

@end
