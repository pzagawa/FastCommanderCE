//
//  FMFileFolderOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 25.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileFolderOperation.h"
#import "FMFileItem.h"
#import "FMOperationFolderWindow.h"
#import "FMPanelListProvider.h"

@implementation FMFileFolderOperation
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
    [FMOperationFolderWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //process
    FMFileItem *fileItem = [FMFileItem fromFilePath:@""];
    
    [self processFileItem:fileItem];
    
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
        
        NSString *newFilePath = fileItem.targetFilePath;
        
        BOOL isSuccess = NO;
        
        if ([newFilePath isEqualToString:self.sourceProvider.currentPath])
        {
            isSuccess = YES;
        }
        else
        {
            isSuccess = [self.sourceProvider createDirectory:newFilePath];
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
    [FMOperationFolderWindow close];
    
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
    FMFileFolderOperation *folderOperation = [[FMFileFolderOperation alloc] initWithProvider:source andTarget:target];

    //block after finishing rename
    OnOperationFinish onCreateFolderFinish = ^(FMFileOperation *operation)
    {
        //if previous operation was not canceled
        if (folderOperation.isCanceled == NO)
        {
        }
    };

    //run operation
    [folderOperation run:onCreateFolderFinish];
}

@end
