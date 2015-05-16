//
//  FMOperationSearchWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 19.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationSearchWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMFileOperationUserData.h"
#import "FMFileItem.h"
#import "FMFileSearchOperation.h"
#import "FMDockInfoView.h"

@implementation FMOperationSearchWindow
{
    int _foundFiles;
    int _foundDirs;
    
    NSString *_statusText;
    int _textMatchFiles;
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
    [self enableProgress:YES];
    
    [super actionAccept:sender];
}

- (void)actionShow:(id)sender
{
    FMFileSearchOperation *searchOperation = (FMFileSearchOperation *)self.fileOperation;

    searchOperation.cancelAndShow = YES;

    [self.fileOperation requestCancel];
}

- (void)actionClose:(id)sender
{
    [super actionAccept:sender];
}

- (void)showAcceptButton
{
    [self.btnAccept setHidden:NO];
    [self.btnShow setHidden:YES];
    [self.btnClose setHidden:YES];

    [self makeFirstResponder:self.btnAccept];
}

- (void)showShowButton
{
    [self.btnShow setFrameOrigin:self.btnAccept.frame.origin];
    
    [self.btnAccept setHidden:YES];
    [self.btnShow setHidden:NO];
    [self.btnClose setHidden:YES];

    [self makeFirstResponder:self.btnShow];
}

- (void)showCloseButton
{
    [self.btnClose setFrameOrigin:self.btnAccept.frame.origin];
    
    [self.btnAccept setHidden:YES];
    [self.btnShow setHidden:YES];
    [self.btnClose setHidden:NO];
    
    [self makeFirstResponder:self.btnClose];
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
    
    self.textTitle.stringValue = @"SEARCHING FILES";
    
    [self showAcceptButton];

    [self enableProgress:NO];
    
    self.textSearchIn.stringValue = self.fileOperation.inputListItemsSummaryText;

    self.editFilePatterns.tokenizingCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    self.editFilePatterns.objectValue = [NSArray arrayWithObject:@"*"];

    self.editSearchText.stringValue = @"";
    
    self.textSearchStatus.stringValue = @"";
    
    [self.editFilePatterns setEditable:YES];
    [self.editSearchText setEditable:YES];
}

- (NSString *)acceptTitle
{
    return @"Search";
}

- (void)beforeStart
{
    [super beforeStart];
    
    self->_foundFiles = 0;
    self->_foundDirs = 0;
    
    self->_statusText = @"";
    self->_textMatchFiles = 0;
    
    [self makeFirstResponder:self.editFilePatterns];
    
    [self.editFilePatterns.currentEditor moveToEndOfLine:nil];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    [super itemStart:fileItem];
    
    if (fileItem.isDirectory)
    {
        self->_foundDirs++;
    }
    else
    {
        self->_foundFiles++;
    }
    
    self.textSearchStatus.stringValue = self.searchStatusText;
}

- (void)itemFinish:(FMFileItem *)fileItem
{
    [super itemFinish:fileItem];
    
    if (_statusText.length == 0)
    {
        _statusText = [self.textSearchStatus.stringValue copy];
    }

    if (fileItem.isDirectory == NO)
    {
        _textMatchFiles++;

        NSString *text = [NSString stringWithFormat:@"%@\ntext found in %d files", _statusText, _textMatchFiles];
        
        self.textSearchStatus.stringValue = text;
    }
}

- (NSString *)searchStatusText
{
    NSString *text = @"";
    
    if (self->_foundFiles > 0 && self->_foundDirs == 0)
    {
        text = [NSString stringWithFormat:@"name match for %d files", self->_foundFiles];
    }
    
    if (self->_foundFiles == 0 && self->_foundDirs > 0)
    {
        text = [NSString stringWithFormat:@"name match for %d directories", self->_foundDirs];
    }
    
    if (self->_foundFiles > 0 && self->_foundDirs > 0)
    {
        text = [NSString stringWithFormat:@"name match for %d directories and %d files", self->_foundDirs, self->_foundFiles];
    }
    
    return text;
}

- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData
{
    [super updateUserInterfaceStateWithUserData:userData];
    
    self.editFilePatterns.objectValue = userData.globFilePatterns;
}

- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData
{
    [super updateUserDataWithUserInterfaceState:userData];
    
    userData.globFilePatterns = [self.editFilePatterns.objectValue copy];
    
    userData.searchText = self.searchText;
    
    [self.editFilePatterns setEditable:NO];
    [self.editSearchText setEditable:NO];

    [self showShowButton];
    
    [self.fileOperation.dockInfoView showIndeterminate];
}

- (NSString *)searchText
{
    return [self.editSearchText.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)afterFinish
{
    [self enableProgress:NO];

    if (self.fileOperation.fileItems.count == 0)
    {
        self.textSearchStatus.stringValue = @"";
        
        [self showCloseButton];
    }
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
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationSearch;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationSearch;
    
    [window closeSheet];
}

@end
