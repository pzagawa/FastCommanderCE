//
//  FMFileSearchOperation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 19.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileSearchOperation.h"
#import "FMPanelListProvider.h"
#import "FMPanelListItem.h"
#import "FMFileItem.h"
#import "FMFileOperationUserData.h"
#import "FMOperationSearchWindow.h"
#import "FMProcessSearchFile.h"
#import "fnmatch.h"
#import "AppDelegate.h"

@implementation FMFileSearchOperation
{
    NSArray *_patternList;
    char **_cPatterns;
}

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
        self->_patternList = nil;
        self->_cPatterns = nil;
        
        self.cancelAndShow = NO;
        
        [self updateInputListItems];
    }
    
    return self;
}

-(void)dealloc
{
    if (self->_cPatterns != nil)
    {
        free(self->_cPatterns);
    }
}

- (void)updateInputListItems
{
    int countDirs = self.inputDirectoryItemsCount;
    int countFiles = self.inputFileItemsCount;
    
    //if no selection, add current directory
    if (countDirs == 0 && countFiles == 0)
    {
        NSURL *url = [NSURL fileURLWithPath:self.sourceProvider.currentPath];

        FMPanelListItem *listItem = [[FMPanelListItem alloc] initWithURL:url itemType:FMPanelListItemTypeDefault];
        
        [self.inputListItems addObject:listItem];
    }
}

- (void)run:(OnOperationFinish)onFinish
{
    [FMOperationSearchWindow showSheet:self];
    
    [super run:onFinish];
}

- (void)initializePatternsToMatchTest:(NSArray *)patternList
{
    self->_patternList = [patternList copy];
    
    self->_cPatterns = malloc(self->_patternList.count * sizeof(char *));

    int index = 0;
    
    for (NSString *pattern in self->_patternList)
    {
        char *cPattern = (char *)pattern.UTF8String;
     
        self->_cPatterns[index] = cPattern;
        
        index++;
    }
}

- (BOOL)isFileItemMatch:(FMFileItem *)fileItem
{
    const char* cFileName = fileItem.fileName.UTF8String;
    
    for (int index = 0; index < self->_patternList.count; index++)
    {
        const char* cPattern = self->_cPatterns[index];
        
        if (fnmatch(cPattern, cFileName, FNM_CASEFOLD) == 0)
        {
            return YES;
        }
    }

    return NO;
}

- (NSArray *)globFilePatternsFromInput
{
    NSMutableSet *patterns = [[NSMutableSet alloc] init];

    for (FMPanelListItem *listItem in self.inputListItems)
    {
        NSString *ext = listItem.fileExtension;
        
        if (ext != nil)
        {
            [patterns addObject:[NSString stringWithFormat:@"*.%@", listItem.fileExtension]];
        }
    }
    
    if (patterns.count == 0)
    {
        [patterns addObject:@"*"];
    }
    
    return [patterns allObjects];
}

- (void)runOnNewThread
{
    //init ui before start
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate beforeStart];
    });
    
    self.userData.globFilePatterns = [self globFilePatternsFromInput];

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

    //SYNC update from UI
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate updateUserDataWithUserInterfaceState:self.userData];
    });

    [self initializePatternsToMatchTest:self.userData.globFilePatterns];

    const BOOL isTextSearch = (self.userData.searchText.length > 0) ? YES : NO;

    //create list of FMFileItem by glob patterns
    self.fileItems = [self.sourceProvider createFileItemsForOperation:self withDeepIteration:YES andTestBlock:^BOOL(FMFileItem *fileItem)
    {
        //skip zero sized files
        if (isTextSearch && fileItem.fileSize == 0)
        {
            return NO;
        }

        //test name match
        if ([self isFileItemMatch:fileItem])
        {
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                [self.progressDelegate itemStart:fileItem];
            });

            return YES;
        }

        return NO;
    }];
    
    //searching text content in file items
    if (isTextSearch)
    {
        //sort input by file size. Start content search from small files first
        [self.fileItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            FMFileItem *itemA = (FMFileItem *)obj1;
            FMFileItem *itemB = (FMFileItem *)obj2;
            
            return (itemA.fileSize > itemB.fileSize);
        }];
        
        //search in files
        FMProcessSearchFile *searchProcessor = [[FMProcessSearchFile alloc] initWithFileOperation:self andText:self.userData.searchText];
        
        NSMutableArray *fileItemsWithContent = [[NSMutableArray alloc] initWithCapacity:self.fileItems.count];
        
        for (FMFileItem *fileItem in self.fileItems)
        {
            if (fileItem.isDirectory == NO)
            {
                [searchProcessor searchTextInFileItem:fileItem];
                
                if (searchProcessor.matchFound)
                {
                    [fileItemsWithContent addObject:fileItem];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^
                    {
                        [self.progressDelegate itemFinish:fileItem];
                    });
                }
            }
            
            //check if operation canceled
            if (self.isCanceled)
            {
                break;
            }
        }

        self.fileItems = fileItemsWithContent;
    }

    //finish item operation
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [self.progressDelegate afterFinish];
    });
    
    //pause if nothing found
    if (self.fileItems.count == 0)
    {
        [NSThread sleepForTimeInterval:0.5];
    }
}

- (void)reloadSearchPanelWithFileItems:(NSMutableArray *)fileItems
{
    NSString *searchProviderTitle = [NSString stringWithFormat:@"SEARCH:%@", self.userData.globFilePatternsText];
    
    [AppDelegate.this setSearchProviderWithData:fileItems andTitle:searchProviderTitle];
}

- (void)finishOnUiThread
{
    [FMOperationSearchWindow close];
    
    if (self.isCanceled == NO || self.cancelAndShow)
    {
        if (self.fileItems.count > 0)
        {
            [self reloadSearchPanelWithFileItems:self.fileItems];
        }
    }
}

+ (void)executeOn:(FMPanelListProvider *)provider
{
    //main operation
    FMFileSearchOperation *mainOperation = [[FMFileSearchOperation alloc] initWithProvider:provider andTarget:nil];
    
    //block after finishing main operation
    OnOperationFinish onMainFinish = ^(FMFileOperation *operation)
    {
    };
    
    //start operation
    [mainOperation run:onMainFinish];
}

@end
