//
//  FMFileDeleteOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 17.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileDeleteOperation.h"
#import "FMFileAnalyzingOperation.h"
#import "FMFileItem.h"
#import "FMPanelListProvider.h"
#import "FMOperationDeleteWindow.h"

@implementation FMFileDeleteOperation

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
    [FMOperationDeleteWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)runOnNewThread
{   
    //file items from first level of panel view, without deeep iteration
    NSMutableArray *panelFileItems = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:NO];

    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //check if paused before explicit user start
    if (self.isPaused)
    {
        [self waitOnResume];
    }
    
    //SYNC update from UI
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate updateUserDataWithUserInterfaceState:self.userData];
    });

    //check if operation canceled
    if (self.isCanceled == NO)
    {
        self.isDataChanged = YES;
        
        for (FMFileItem *fileItem in panelFileItems)
        {
            BOOL isSuccess = NO;
            
            if (fileItem.isDirectory)
            {
                isSuccess = [self.sourceProvider removeDirectory:fileItem.filePath];
            }
            else
            {
                isSuccess = [self.sourceProvider removeFile:fileItem.filePath];
            }
            
            if (isSuccess == NO)
            {
                [fileItem setStatus:FMFileItemStatus_SOURCE_REMOVE_ERROR];
            }
                        
            //check if operation paused
            if (self.isPaused)
            {
                [self waitOnResume];
            }
            
            //check if operation canceled
            if (self.isCanceled)
            {
                break;
            }
        }
    }

    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
}

- (void)finishOnUiThread
{
    [FMOperationDeleteWindow close];
    
    if (self.isDataChanged)
    {
        [self reloadSourcePanel:^(FMReloadData *data){}];
    }
}

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target
{
    //delete operation
    FMFileDeleteOperation *deleteOperation = [[FMFileDeleteOperation alloc] initWithProvider:source andTarget:target];

    //block after finishing delete
    OnOperationFinish onDeleteFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (deleteOperation.isCanceled == NO)
        {
        }
    };
    
    //analyze source operation
    FMFileAnalyzingOperation *analyzingOperation = [[FMFileAnalyzingOperation alloc] initWithProvider:source andTarget:target];
    
    //block after finishing analyzing
    OnOperationFinish onAnalyzingFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (analyzingOperation.isCanceled == NO)
        {
            //retain parent reference to child object
            deleteOperation.fileItems = analyzingOperation.fileItems;
            
            //release parent strong reference
            analyzingOperation.fileItems = nil;
            
            //continue with new operation
            [deleteOperation run:onDeleteFinish];
        }
    };
    
    //start operation
    [analyzingOperation run:onAnalyzingFinish];
}

@end
