//
//  FMOperationDeleteWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 17.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationDeleteWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMDockInfoView.h"

@implementation FMOperationDeleteWindow

- (void)actionCancel:(id)sender
{
    if (self.fileOperation.isInProgress)
    {
        [super actionCancel:sender];
    }
    else
    {
        [self closeSheet];
    }
}

- (void)actionAccept:(id)sender
{
    [self enableProgress:YES];

    [super actionAccept:sender];
}

- (void)enableProgress:(BOOL)enabled
{
    if (enabled)
    {
        [self.operationProgress startAnimation:self];
        [self.operationProgress displayIfNeeded];
    }
    else
    {
        [self.operationProgress stopAnimation:self];
    }
}

//FMFileOperationProgress protocol
- (void)reset
{
    [super reset];
    
    self.textTitle.stringValue = @"DELETING FILES";

    self.textTotalFilesInfo.stringValue = @"";
    self.textTotalSizeInfo.stringValue = @"";
    
    [self enableProgress:NO];
}

- (NSString *)acceptTitle
{
    return @"Delete";
}

- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData
{
    [self.fileOperation.dockInfoView showIndeterminate];
}

- (void)beforeStart
{
    [super beforeStart];

    self.textTotalFilesInfo.stringValue = [NSString stringWithFormat:@"%lu", self.fileOperation.filesTotalCount.integerValue];
    self.textTotalSizeInfo.stringValue = [NSString stringWithFormat:@"%@", self.fileOperation.filesTotalSizeText];
}

- (void)afterFinish
{
}

- (void)onOperationPause:(BOOL)pauseState
{
    
}

- (void)closeSheet
{
    [super closeSheet];
    
    [self.fileOperation.dockInfoView hide];
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationDelete;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationDelete;
    
    [window closeSheet];
}

@end
