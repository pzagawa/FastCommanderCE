//
//  FMOperationFolderWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationFolderWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMFileItem.h"

@implementation FMOperationFolderWindow
{
    NSString *_directoryName;
}

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
    [super actionAccept:sender];
}

//FMFileOperationProgress protocol
- (void)reset
{
    [super reset];
    
    self.textTitle.stringValue = @"NEW DIRECTORY";
    self.editDirectory.stringValue = @"";

    [self.viewError setHidden:YES];
}

- (NSString *)acceptTitle
{
    return @"Create";
}

- (void)beforeStart
{
    [super beforeStart];
    
    self->_directoryName = nil;
}

- (void)itemStart:(FMFileItem *)fileItem
{
    [self reset];

    if (_directoryName != nil)
    {
        self.editDirectory.stringValue = _directoryName;
    }
    
    //update error message
    [self.viewError setHidden:(fileItem.isError == NO)];

    //request edit as first reponder
    [self makeFirstResponder:self.editDirectory];
}

- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem
{
    NSString *newDirectoryName = [self.editDirectory.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *fileName = [self.fileOperation.sourceProvider.currentPath stringByAppendingPathComponent:newDirectoryName];

    self->_directoryName = [newDirectoryName copy];
    
    fileItem.targetFilePath = [fileName copy];
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
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationFolder;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationFolder;
    
    [window closeSheet];
}

@end
