//
//  FMFileCalcSizeOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 03.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileCalcSizeOperation.h"
#import "FMOperationAnalyzingWindow.h"
#import "FMDirectoryViewController.h"
#import "FMFileItem.h"
#import "FMPanelListItem.h"
#import "AppDelegate.h"
#import "FMCommand.h"

@implementation FMFileCalcSizeOperation

- (void)run:(OnOperationFinish)onFinish
{
    //show analyzing sheet if any directory selected
    if (self.inputDirectoryItemsCount > 0)
    {
        [FMOperationAnalyzingWindow showSheet:self];
    }
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });

    //process panel list items
    for (FMPanelListItem *listItem in self.inputListItems)
    {
        if (listItem.isDirectory)
        {
            NSString *filePath = listItem.unifiedFilePath;
            
            NSMutableArray *fileItems = [self.sourceProvider createFileItemsForPanelListItem:listItem withOperation:self andTestBlock:^BOOL(FMFileItem *fileItem)
            {
                return YES;
            }];
            
            //sum directory items size
            long long totalSize = 0;
            
            for (FMFileItem *fileItem in fileItems)
            {
                totalSize += fileItem.fileSize;
            }
            
            //check if operation canceled
            if (self.isCanceled)
            {
                break;
            }

            //run SYNC main thread UI update
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                [AppDelegate.this.sourceViewController.tableView updateListItemByFileName:filePath withDirectorySize:totalSize];
            });
        }
    }    
}

- (void)finishOnUiThread
{
    [FMOperationAnalyzingWindow close];
    
    //update selection if directory processed
    if (self.inputDirectoryItemsCount > 0)
    {
        //send select items command for update selection text
        FMCommand *commandSelectItems = [FMCommand selectItems];
         
        commandSelectItems.sourceObject = self;
        commandSelectItems.panelSide = AppDelegate.this.sourcePanelSide;
         
        [commandSelectItems execute];

        //send update summary command for update summary text
        FMCommand *commandUpdateSummary = [FMCommand updateSummary];
        
        commandUpdateSummary.sourceObject = self;
        commandUpdateSummary.panelSide = AppDelegate.this.sourcePanelSide;
        
        [commandUpdateSummary execute];
    }
}

+ (void)executeOn:(FMPanelListProvider *)provider andFinishWithBlock:(OnOperationFinish)onFinish
{
    FMFileCalcSizeOperation *fileOperation = [[FMFileCalcSizeOperation alloc] initWithProvider:provider andTarget:nil];
    
    [fileOperation run:onFinish];
}

@end
