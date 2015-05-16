//
//  FMOperationRenameWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationRenameWindow.h"
#import "FMFileOperation.h"
#import "FMFileRenameOperation.h"
#import "AppDelegate.h"
#import "FMFileItem.h"

@implementation FMOperationRenameWindow

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

- (void)actionSkip:(id)sender
{
    [self.fileOperation requestSkip];
}

//FMFileOperationProgress protocol
- (void)reset
{
    [super reset];
    
    self.textTitle.stringValue = @"RENAME";
    self.editFileName.stringValue = @"";
    
    [self.viewError setHidden:YES];
}

- (void)updateSkipButtonVisibility
{
    if (self.fileOperation.fileItems.count == 1)
    {
        [self showSkipButton:NO];
    }
    else
    {
        [self showSkipButton:YES];
    }
}

- (void)showSkipButton:(BOOL)enabled
{
    NSPoint btnOrigin = self.buttonOrigin;

    NSPoint btnOrigin1 = NSMakePoint(btnOrigin.x - self.buttonSpacing, btnOrigin.y);
    NSPoint btnOrigin2 = NSMakePoint(btnOrigin1.x - self.buttonSpacing, btnOrigin.y);
    
    if (enabled)
    {
        [self.btnCancel setFrameOrigin:btnOrigin1];
        [self.btnSkip setFrameOrigin:btnOrigin2];
        
        [self.btnSkip setHidden:NO];
    }
    else
    {
        [self.btnSkip setHidden:YES];

        [self.btnCancel setFrameOrigin:btnOrigin1];
        [self.btnSkip setFrameOrigin:btnOrigin2];
    }
}

- (NSString *)acceptTitle
{
    return @"Rename";
}

- (void)beforeStart
{
    [super beforeStart];
    
    [self updateSkipButtonVisibility];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    [self reset];
    
    //update title
    if (fileItem.isDirectory)
    {
        self.textTitle.stringValue = @"RENAME DIRECTORY";
    }
    else
    {
        self.textTitle.stringValue = @"RENAME FILE";
    }

    //update name field
    NSString *fileName = [fileItem.filePath lastPathComponent];
    
    self.editFileName.stringValue = fileName;
    
    //update error message
    [self.viewError setHidden:(fileItem.isError == NO)];
    
    //request edit as first reponder
    [self makeFirstResponder:self.editFileName];
}

- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem
{
    NSString *newFileName = [self.editFileName.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *filePath = [fileItem.filePath stringByDeletingLastPathComponent];
    
    NSString *fileName = [filePath stringByAppendingPathComponent:newFileName];
    
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
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationRename;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationRename;
    
    [window closeSheet];
}

@end
