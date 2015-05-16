//
//  FMOperationCompressWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationCompressWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMFileOperationUserData.h"
#import "FMDockInfoView.h"

@implementation FMOperationCompressWindow

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
    
    self.textTitle.stringValue = @"COMPRESSING FILES";
    
    self.editFileName.stringValue = [self archiveFileName];

    [self.editFileName setEditable:YES];

    self.textTotalFilesInfo.stringValue = @"";
    self.textTotalSizeInfo.stringValue = @"";
    
    [self enableProgress:NO];
}

- (NSString *)acceptTitle
{
    return @"Compress";
}

- (NSString *)archiveFileName
{
    if (self.fileOperation.inputDirectoryItemsCount == 1)
    {
        FMPanelListItem *listItem = [self.fileOperation.inputListItems objectAtIndex:0];
        return [listItem.fileName stringByAppendingPathExtension:@"zip"];
    }

    if (self.fileOperation.inputFileItemsCount == 1)
    {
        FMPanelListItem *listItem = [self.fileOperation.inputListItems objectAtIndex:0];
        return [listItem.fileName stringByAppendingPathExtension:@"zip"];
    }
    
    return @"archive.zip";
}

- (void)beforeStart
{
    [super beforeStart];

    self.textTotalFilesInfo.stringValue = [NSString stringWithFormat:@"%lu", self.fileOperation.filesTotalCount.integerValue];
    self.textTotalSizeInfo.stringValue = [NSString stringWithFormat:@"%@", self.fileOperation.filesTotalSizeText];

    //request edit as first reponder
    [self makeFirstResponder:self.editFileName];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    [super itemStart:fileItem];
    
}

- (void)itemFinish:(FMFileItem *)fileItem
{
    [super itemFinish:fileItem];

}

- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData
{
    [super updateUserInterfaceStateWithUserData:userData];
    
}

- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData
{
    [super updateUserDataWithUserInterfaceState:userData];

    NSString *newFileName = [self.editFileName.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    userData.archiveFileName = [self.fileOperation.targetProvider.currentPath stringByAppendingPathComponent:newFileName];
    
    [self.editFileName setEditable:NO];
    
    [self.fileOperation.dockInfoView showIndeterminate];
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
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationCompress;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationCompress;
    
    [window closeSheet];
}

@end
