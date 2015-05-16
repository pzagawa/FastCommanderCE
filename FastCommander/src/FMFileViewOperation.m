//
//  FMFileViewOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 18.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileViewOperation.h"
#import "FMOperationTextViewWindow.h"
#import "FMOperationImageViewWindow.h"
#import "FMFileCalcSizeOperation.h"
#import "FMFileItem.h"
#import "FMPanelListProvider.h"
#import "FMProcessGetFile.h"
#import "NSString+Utils.h"

@implementation FMFileViewOperation
{
    FMProcessGetFile *_processGetFile;
    FMFileViewType _fileViewType;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
        self->_processGetFile = [[FMProcessGetFile alloc] initWithFileOperation:self];
    }
    
    return self;
}

- (void)run:(OnOperationFinish)onFinish
{
    if (self->_fileViewType == FMFileViewType_TEXT)
    {
        [FMOperationTextViewWindow showSheet:self];
    }

    if (self->_fileViewType == FMFileViewType_IMAGE)
    {
        [FMOperationImageViewWindow showSheet:self];
    }
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    const int MAX_FILE_50MB = 1024 * 1024 * 50;

    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });

    //get selected file
    self.fileItems = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:NO];
    
    if (self.fileItems.count == 1)
    {
        FMFileItem *fileItem = [self.fileItems lastObject];

        //handle file on UI side
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemStart:fileItem];
        });
        
        NSData *fileData = nil;
        
        if (fileItem.fileSize < MAX_FILE_50MB)
        {
            //read file to data
            fileData = [self->_processGetFile fileItemAsData:fileItem];

            if (fileData != nil)
            {
                if ((fileData.length != fileItem.fileSize))
                {
                    fileData = nil;
                }
            }
        }
        
        //handle file on UI side
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemStart:fileItem withData:fileData];
        });
    }
    
    //wait if paused state
    if (self.isPaused)
    {
        [self waitOnResume];
    }
    
    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
}

- (void)finishOnUiThread
{
    if (self->_fileViewType == FMFileViewType_TEXT)
    {
        [FMOperationTextViewWindow close];
    }

    if (self->_fileViewType == FMFileViewType_IMAGE)
    {
        [FMOperationImageViewWindow close];
    }
}

+ (void)executeOn:(FMPanelListProvider *)provider
{
    //analyze source operation
    FMFileCalcSizeOperation *calcSizeOperation = [[FMFileCalcSizeOperation alloc] initWithProvider:provider andTarget:nil];
    
    //process directories calc size if selected
    if (calcSizeOperation.inputDirectoryItemsCount > 0)
    {
        //block after finishing
        OnOperationFinish onCalcSizeFinish = ^(FMFileOperation *operation)
        {
            //if previous operation was not canceled
            if (calcSizeOperation.isCanceled == NO)
            {
            }
        };
        
        //start operation
        [calcSizeOperation run:onCalcSizeFinish];
    }
    else
    {
        //process file preview if only one selected
        if (calcSizeOperation.inputFileItemsCount == 1)
        {
            //get selected file
            NSMutableArray *fileItems = [calcSizeOperation.sourceProvider createFileItemsForOperation:calcSizeOperation withDeepIteration:NO];
            
            if (fileItems.count == 1)
            {
                FMFileItem *fileItem = [fileItems lastObject];

                FMFileViewType fileViewType = fileItem.fileViewType;

                if (fileViewType != FMFileViewType_NONE)
                {
                    [FMFileViewOperation runFileView:provider withType:fileViewType];
                }
            }

            return;
        }
    }
}

+ (void)runFileView:(FMPanelListProvider *)provider withType:(FMFileViewType)fileViewType
{
    //View operation
    FMFileViewOperation *viewOperation = [[FMFileViewOperation alloc] initWithProvider:provider andTarget:nil];
    
    viewOperation->_fileViewType = fileViewType;
    
    //block after finishing
    OnOperationFinish onViewFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (viewOperation.isCanceled == NO)
        {
        }
    };
    
    //start operation
    [viewOperation run:onViewFinish];
}

@end
