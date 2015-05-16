//
//  FMFilePermissionsOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 21.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFilePermissionsOperation.h"
#import "FMFileAnalyzingOperation.h"
#import "FMOperationPermissionsWindow.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMPosixPermissions.h"
#import "FMFileOperationUserData.h"

@implementation FMFilePermissionsOperation
{
    FMPosixPermissions *_posixPermissions;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
        self->_posixPermissions = [[FMPosixPermissions alloc] init];
    }
    
    return self;
}

- (void)run:(OnOperationFinish)onFinish
{
    [FMOperationPermissionsWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)runOnNewThread
{
    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    //file items from first level of panel view, without deeep iteration
    NSMutableArray *fileItemsToProcess = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:NO];
    
    [self->_posixPermissions aggregateFileItemsPermissions:fileItemsToProcess withProvider:self.sourceProvider];
    
    //SYNC update UI with user data
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        self.userData.aggregatedPermissionsToSet = self->_posixPermissions.bitsToSet;
        self.userData.aggregatedPermissionsToClear = self->_posixPermissions.bitsToClear;
        
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

    //SYNC update from UI
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        self.userData.isProcessSubdirectories = NO;

        [self.progressDelegate updateUserDataWithUserInterfaceState:self.userData];
    });
    
    //get ui state
    if (self.userData.isProcessSubdirectories)
    {
        fileItemsToProcess = self.fileItems;
    }
    
    NSUInteger bitsToSet = self.userData.aggregatedPermissionsToSet;
    NSUInteger bitsToClear = self.userData.aggregatedPermissionsToClear;
    
    //process file items
    self.isDataChanged = YES;
    
    for (FMFileItem *fileItem in fileItemsToProcess)
    {
        NSUInteger permissions = [self.sourceProvider posixPermissionsForPath:fileItem.filePath];
        
        //merge set and clear bits
        permissions &= ~bitsToClear;
        permissions |= bitsToSet;
        
        //update permissions
        [self.sourceProvider setPosixPermissions:permissions forPath:fileItem.filePath];
        
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

- (void)finishOnUiThread
{
    [FMOperationPermissionsWindow close];
    
    if (self.isDataChanged)
    {
        [self reloadSourcePanel:^(FMReloadData *data){}];
    }
}

+ (void)executeOn:(FMPanelListProvider *)provider
{
    //main operation
    FMFilePermissionsOperation *mainOperation = [[FMFilePermissionsOperation alloc] initWithProvider:provider andTarget:nil];
    
    //block after finishing main operation
    OnOperationFinish onMainFinish = ^(FMFileOperation *operation)
    {
    };
    
    //analyze source operation
    FMFileAnalyzingOperation *analyzingOperation = [[FMFileAnalyzingOperation alloc] initWithProvider:provider andTarget:nil];
    
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
