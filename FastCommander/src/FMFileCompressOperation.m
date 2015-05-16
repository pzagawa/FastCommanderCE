//
//  FMFileCompressOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileCompressOperation.h"
#import "FMFileAnalyzingOperation.h"
#import "FMFileOperation.h"
#import "FMOperationCompressWindow.h"
#import "FMPanelListProvider.h"
#import "FMFileOperationUserData.h"
#import "FMFileItem.h"
#import "NSString+Utils.h"

#import "zipzap.h"

@implementation FMFileCompressOperation

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
    [FMOperationCompressWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //SYNC update UI with user data
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate updateUserInterfaceStateWithUserData:self.userData];
    });
    
    //check if paused before explicit user start
    if (self.isPaused)
    {
        [self waitOnResume];
    }
    
    //check if operation canceled
    if (self.isCanceled)
    {
        return;
    }
    
    //SYNC update user data from UI
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate updateUserDataWithUserInterfaceState:self.userData];
    });
    
    //create archive file
    NSURL *archiveFileUrl = [NSURL fileURLWithPath:self.userData.archiveFileName];
    
    ZZMutableArchive *_archive = [ZZMutableArchive archiveWithContentsOfURL:archiveFileUrl];

    NSMutableArray* newArchiveEntries = [NSMutableArray array];
    
    self.isDataChanged = YES;
    
    //process file items
    for (FMFileItem *fileItem in self.fileItems)
    {
        //SYNC start file operation dispatch to avoid bugs
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemStart:fileItem];
        });

        //create target archive filename
        NSString *relativeFileName = [self.sourceProvider getRelativeTargetFileName:fileItem withTargetPath:self.targetProvider.currentPath];

        ZZArchiveEntry *archiveEntry = nil;
        
        //read local file to buffer
        NSData *data = [NSData dataWithContentsOfFile:fileItem.filePath];

        //add archive entry to array
        if (data == nil)
        {
            [fileItem setStatus:FMFileItemStatus_INPUT_OPEN_ERROR];
        }
        else
        {
            if (fileItem.isDirectory)
            {
                NSString *relativeDirectoryName = [relativeFileName stringByAppendingSlashSuffix];
                
                archiveEntry = [ZZArchiveEntry archiveEntryWithDirectoryName:relativeDirectoryName];
            }
            else
            {
                archiveEntry = [ZZArchiveEntry archiveEntryWithFileName:relativeFileName compress:YES dataBlock:^(NSError** error)
                {
                    return data;
                }];
            }

            [newArchiveEntries addObject:archiveEntry];

            [fileItem setStatus:FMFileItemStatus_DONE];
        }
        
        //SYNC finish item operation
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate itemFinish:fileItem];
        });
        
        //check if operation canceled
        if (self.isCanceled)
        {
            break;
        }
    }

    //compress items to archive
    [_archive updateEntries:newArchiveEntries error:nil];
    
    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
}

- (void)finishOnUiThread
{
    [FMOperationCompressWindow close];
    
    if (self.isDataChanged)
    {
        [self reloadTargetPanel:^(FMReloadData *data){}];
    }
}

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target
{
    //main operation
    FMFileCompressOperation *mainOperation = [[FMFileCompressOperation alloc] initWithProvider:source andTarget:target];
    
    //block after finishing main operation
    OnOperationFinish onMainFinish = ^(FMFileOperation *operation)
    {
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
            mainOperation.fileItems = analyzingOperation.fileItems;
            
            //release parent strong reference
            analyzingOperation.fileItems = nil;
            
            //continue with new operation
            [mainOperation run:onMainFinish];
        }
    };
    
    //start operation
    [analyzingOperation run:onAnalyzingFinish];
}

@end
