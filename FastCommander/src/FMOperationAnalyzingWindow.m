//
//  FMOperationAnalyzingWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationAnalyzingWindow.h"
#import "AppDelegate.h"
#import "FMFileOperation.h"
#import "FMDockInfoView.h"

@implementation FMOperationAnalyzingWindow

- (void)actionCancel:(id)sender
{
    [super actionCancel:sender];
}

- (void)actionAccept:(id)sender
{
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

- (void)reset
{
    [super reset];

    self.textTitle.stringValue = @"ANALYZING FILES";
    
    [self enableProgress:NO];
}

- (void)beforeStart
{
    [super beforeStart];

    [self enableProgress:YES];
    
    [self.fileOperation.dockInfoView showIndeterminate];
}

- (void)closeSheet
{
    [super closeSheet];
    
    [self.fileOperation.dockInfoView hide];
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationAnalyzing;

    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationAnalyzing;
    
    [window closeSheet];
}

@end
