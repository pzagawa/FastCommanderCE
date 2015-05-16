//
//  FMFileRenameOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileRenameOperation.h"
#import "FMFileItem.h"
#import "FMPanelListProvider.h"
#import "FMOperationRenameWindow.h"

@implementation FMFileRenameOperation
{
    NSString *_nameToSelectOnList;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
    }
    
    return self;
}

- (void)run:(OnOperationFinish)onFinish
{
    [FMOperationRenameWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    //file items from first level of panel view, without deeep iteration
    self.fileItems = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:NO];

    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //process items
    for (FMFileItem *fileItem in self.fileItems)
    {
        [self processFileItem:fileItem];

        //check if operation canceled
        if (self.isCanceled)
        {
            break;
        }        
    }

    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
}

- (void)processFileItem:(FMFileItem *)fileItem
{
    while (YES)
    {
        //update UI before item processing
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemStart:fileItem];
        });
        
        //pause and wait for UI to resume operation
        if (self.isPaused)
        {
            [self waitOnResume];
        }
        
        //check if operation skipped
        if (self.isSkipRequest)
        {
            [self requestPause];
            [self resetUserActionRequests];
            break;
        }

        //check if operation canceled
        if (self.isCanceled)
        {
            break;
        }

        //allow update fileItem UI
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate updateFileItemBeforeStart:fileItem];
        });
        
        //process operation
        self.isDataChanged = YES;

        NSString *oldFilePath = fileItem.filePath;
        NSString *newFilePath = fileItem.targetFilePath;
        
        BOOL isSuccess = NO;
        
        if ([oldFilePath isEqualToString:newFilePath])
        {
            isSuccess = YES;
        }
        else
        {
            NSComparisonResult result = [oldFilePath caseInsensitiveCompare:newFilePath];
            
            if (result == NSOrderedSame)
            {
                NSString *tmpNewFilePath = [NSString stringWithFormat:@"%@_tmpname", newFilePath];
                
                isSuccess = [self.sourceProvider renameFile:oldFilePath to:tmpNewFilePath];
                
                if (isSuccess == YES)
                {
                    isSuccess = [self.sourceProvider renameFile:tmpNewFilePath to:newFilePath];
                }
            }
            else
            {
                isSuccess = [self.sourceProvider renameFile:oldFilePath to:newFilePath];
            }
        }
        
        //check result
        if (isSuccess)
        {
            [fileItem setStatus:FMFileItemStatus_DONE];
            
            [self requestPause];
            
            self->_nameToSelectOnList = [newFilePath lastPathComponent];

            break;
        }
        else
        {
            [fileItem setStatus:FMFileItemStatus_ERROR];
            [self requestPause];
        }
    }
}

- (void)finishOnUiThread
{
    [FMOperationRenameWindow close];
    
    if (self.isDataChanged)
    {
        [self reloadSourcePanel:^(FMReloadData *data)
        {
            data.nameToSelectOnList = self->_nameToSelectOnList;
        }];
    }
}

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target
{
    //operation
    FMFileRenameOperation *renameOperation = [[FMFileRenameOperation alloc] initWithProvider:source andTarget:target];

    //block after finishing rename
    OnOperationFinish onRenameFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (renameOperation.isCanceled == NO)
        {
        }
    };

    //run operation
    [renameOperation run:onRenameFinish];
}

@end
