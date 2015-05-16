//
//  FMFileOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 31.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <mach/mach_time.h>
#import "FMFileOperation.h"
#import "FMPanelListProvider.h"
#import "FMDirectoryViewController.h"
#import "FMFileItem.h"
#import "AppDelegate.h"
#import "FMDockInfoView.h"
#import "NSString+Utils.h"
#import "FMFileOperationUserData.h"
#import "FMSearchPanelListProvider.h"

@implementation FMFileOperation
{
    NSOperationQueue *_queue;
    NSCondition *_conditionResume;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super init];
    
    if (self)
    {
        AppDelegate.this.mainViewController.activeFileOperation = self;
        
        self.isDataChanged = NO;
        
        self->_queue = [[NSOperationQueue alloc] init];
        self->_conditionResume = [[NSCondition alloc] init];
        
        self->_userAction = [[FMOperationUserAction alloc] init];
        self->_userData = [[FMFileOperationUserData alloc] init];
        
        //prepare panel list items for processing
        self.inputListItems = [source getListItemsForOperation];
        
        //prepare array for result file items after processing
        self.fileItems = [[NSMutableArray alloc] initWithCapacity:1000];
                
        self.sourceProvider = source;
        self.targetProvider = target;
        
        //prepare dock tile
        self->_dockInfoView = [FMDockInfoView createDockInfoView];

        //reset operation
        [self resetState];
    }
    
    return self;
}

-(void)dealloc
{
    AppDelegate.this.mainViewController.activeFileOperation = nil;
}

- (void)resetState
{
    self->_filesTotalCount = @0;
    self->_filesTotalSize = @0;

    self->_directoriesTotalCount = @0;

    self->_isCanceled = NO;
    self->_isInProgress = NO;
    self->_isPaused = YES;

    [self resetUserActionRequests];
    
    [self.userAction reset];
}

- (void)resetUserActionRequests
{
    self->_isSkipRequest = NO;
    self->_isRetryRequest = NO;
    self->_isOverwriteRequest = NO;
}

- (void)requestCancel
{
    [self requestResume];
    
    self->_isCanceled = YES;

    [self->_conditionResume broadcast];
}

- (void)requestPause
{
    self->_isPaused = YES;
}

- (void)requestResume
{
    self->_isPaused = NO;

    [self->_conditionResume broadcast];
}

- (void)waitOnResume
{
    [self->_conditionResume lock];
    [self->_conditionResume wait];
    [self->_conditionResume unlock];
}

- (void)requestSkip
{
    self->_isSkipRequest = YES;

    [self requestResume];
}

- (void)requestRetry
{
    self->_isRetryRequest = YES;

    [self requestResume];
}

- (void)requestOverwrite
{
    self->_isOverwriteRequest = YES;
    
    [self requestResume];
}

- (void)updateFilesTotalStats
{
    int filesTotalCount = 0;
    long long filesTotalSize = 0;

    int directoriesTotalCount = 0;
    
    for (FMFileItem *fileItem in self.fileItems)
    {
        if (fileItem.isDirectory)
        {
            directoriesTotalCount++;
        }
        else
        {
            filesTotalCount++;
            filesTotalSize += fileItem.fileSize;
        }
    }
    
    self->_filesTotalCount = [NSNumber numberWithInt:filesTotalCount];
    self->_filesTotalSize = [NSNumber numberWithLongLong:filesTotalSize];

    self->_directoriesTotalCount = [NSNumber numberWithInt:directoriesTotalCount];
}

- (void)run:(OnOperationFinish)onFinish
{
    self->_isInProgress = YES;
    
    //start on new thread
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        [self updateFilesTotalStats];
        
        [self runOnNewThread];

        //reset sheet ui on finish because lack of before show event
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            [self.progressDelegate reset];
        });        
    }];
    
    [operation setCompletionBlock:^
    {
        //finish on UI thread
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self finishOnUiThread];

            self->_isInProgress = NO;
            
            onFinish(self);
        });
    }];
    
    [_queue addOperation:operation];
}

- (void)runOnNewThread
{
}

- (void)finishOnUiThread
{
}

- (int)inputDirectoryItemsCount
{
    int count = 0;
    
    for (FMPanelListItem *listItem in self.inputListItems)
    {
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            if (listItem.isDirectory == YES)
            {
                count++;
            }
        }
    }
    
    return count;
}

- (int)inputFileItemsCount
{
    int count = 0;
    
    for (FMPanelListItem *listItem in self.inputListItems)
    {
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            if (listItem.isDirectory == NO)
            {
                count++;
            }
        }
    }
    
    return count;
}

- (NSString *)inputListItemsSummaryText
{
    int countDirs = 0;
    int countFiles = 0;
    
    NSMutableString *text = [[NSMutableString alloc] init];
    
    for (FMPanelListItem *listItem in self.inputListItems)
    {
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            if (text.length == 0)
            {
                NSString *path = listItem.unifiedFilePath;
                
                if (listItem.isDirectory == NO)
                {
                    path = [path stringByDeletingLastPathComponent];
                }
                
                [text appendString:path];

                if (listItem.isDirectory)
                {
                    countDirs--;
                }
                else
                {
                    countFiles--;
                }
            }
            
            if (listItem.isDirectory)
            {
                countDirs++;
            }
            else
            {
                countFiles++;
            }
        }
    }
    
    if (countDirs > 0 && countFiles == 0)
    {
        if (countDirs == 1)
        {
            [text appendFormat:@"\nand %d other directory", countDirs];
        }
        else
        {
            [text appendFormat:@"\nand %d other directories", countDirs];
        }
    }

    if (countFiles > 0 && countDirs == 0)
    {
        if (countFiles == 1)
        {
            [text appendFormat:@"\nand %d other file", countFiles];
        }
        else
        {
            [text appendFormat:@"\nand %d other files", countFiles];
        }
    }

    if (countFiles > 0 && countDirs > 0)
    {
        [text appendFormat:@"\nand %d other directories, %d other files", countDirs, countFiles];
    }

    return text;
}

- (NSString *)filesTotalSizeText
{
    return [NSByteCountFormatter stringFromByteCount:self->_filesTotalSize.longValue countStyle:NSByteCountFormatterCountStyleFile];
}

- (BOOL)filesTotalCountIsOne
{
    if (self.filesTotalCount.integerValue == 1)
    {
        return YES;
    }
    
    return NO;
}

- (long)secsFromKernelTime:(uint64_t)time
{
    static mach_timebase_info_data_t timebase;
    
    if (timebase.denom == 0)
    {
        mach_timebase_info(&timebase);
    }
    
    return (double)time * (double)timebase.numer / (double)timebase.denom / 1e9;
}

- (long)milisFromKernelTime:(uint64_t)time
{
    static mach_timebase_info_data_t timebase;
    
    if (timebase.denom == 0)
    {
        mach_timebase_info(&timebase);
    }
    
    return (double)time * (double)timebase.numer / (double)timebase.denom / 1e6;
}

- (void)reloadSourcePanel:(OnReloadBlock)onReloadFinish
{
    [AppDelegate.this reloadSourcePanel:onReloadFinish];
}

- (void)reloadTargetPanel:(OnReloadBlock)onReloadFinish
{
    [AppDelegate.this reloadTargetPanel:onReloadFinish];
}

- (void)reloadBothPanels
{
    [AppDelegate.this reloadBothPanels];
}

@end
