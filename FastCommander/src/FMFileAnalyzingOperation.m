//
//  FMFileAnalyzingOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 03.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileAnalyzingOperation.h"
#import "FMOperationAnalyzingWindow.h"
#import "FMDirectoryViewController.h"
#import "FMFileItem.h"

@implementation FMFileAnalyzingOperation

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

    self.fileItems = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:YES];
}

- (void)finishOnUiThread
{
    [FMOperationAnalyzingWindow close];
}

+ (void)executeOn:(FMPanelListProvider *)provider andFinishWithBlock:(OnOperationFinish)onFinish
{
    FMFileAnalyzingOperation *fileOperation = [[FMFileAnalyzingOperation alloc] initWithProvider:provider andTarget:nil];
    
    [fileOperation run:onFinish];
}

@end
