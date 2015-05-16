//
//  FMPanelListProvider.m
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPanelListProvider.h"
#import "FMDirectoryViewController.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMPanelListItem.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "FMOperationCommandSupport.h"
#import "FMSettings.h"

@implementation FMPanelListProvider
{
    NSMutableArray *_listItems;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.providerTitle = @"";

        self->_listItems = [[NSMutableArray alloc] initWithCapacity:2000];

        self.providerName = @"(unknown panel list provider)";
        
        self.maximumSupportedFileSize = nil;

        self->_commandSupport = [[FMOperationCommandSupport alloc] init];
        
        [self initCommandSupport:self->_commandSupport];
    }
    
    return self;
}

- (void)initCommandSupport:(FMOperationCommandSupport *)support
{
}

- (BOOL)currentPathContentChanged
{
    return NO;
}

- (BOOL)isUseTrash
{
    return [[FMSettings instance] isUseTrash];
}

- (void)resetPathContentChanged
{
}

- (void)reset
{
    _listItems = [[NSMutableArray alloc] initWithCapacity:2000];
}

- (void)initBasePath:(NSString *)path
{
    self.basePath = path;
    self.currentPath = path;
}

/*
 
 PATH FORMAT: <resource:directory>, for example:

 local path:
    /Users/guest/file.zip:/zip_directory

 search path:
    search:text in *
 
 ftp path:
    ftp:directory_path
 
 plugin path:
    plugin:result
 
*/
- (BOOL)isPathValid:(NSString *)path
{
    return NO;
}

- (void)reload
{
}

- (void)reload:(NSString *)path
{
    if (self.currentPath == nil)
    {
        self.previousPath = path;
    }
    else
    {
        self.previousPath = self.currentPath;
    }
    
    self.currentPath = path;
}

- (void)sortedPanelListFromUrlItems:(NSArray *)urltems parentDirectory:(NSString *)parentDirectory
{
    //create sorting categories
    NSMutableArray *arrayDirs = [[NSMutableArray alloc] init];
    NSMutableArray *arrayFiles = [[NSMutableArray alloc] init];
    
    //fill collections
    for (id item in urltems)
    {
        FMPanelListItem *fileItem = [[FMPanelListItem alloc] initWithURL: item itemType:FMPanelListItemTypeDefault];
        
        if (fileItem.isDirectory)
        {
            [arrayDirs addObject:fileItem];
        }
        else
        {
            [arrayFiles addObject:fileItem];
        }
    }
    
    //sort collections
    [self sortPanelListItemsByName:arrayDirs];
    [self sortPanelListItemsByName:arrayFiles];
    
    //merge items
    _listItems = [[NSMutableArray alloc] init];
    
    //create directory up action ".." item for child folder
    if (parentDirectory != nil)
    {
        FMPanelListItem *actionItemDirUp = [[FMPanelListItem alloc] initWithURL:[NSURL fileURLWithPath:parentDirectory isDirectory:YES] itemType:FMPanelListItemTypeDirUp];
        
        [_listItems addObject:actionItemDirUp];
    }
    
    [_listItems addObjectsFromArray:arrayDirs];
    [_listItems addObjectsFromArray:arrayFiles];
}

- (void)sortedPanelListFromPanelListItems:(NSMutableArray *)listItems parentDirectory:(FMPanelListItem *)parentDirectory
{
    //create sorting categories
    NSMutableArray *arrayDirs = [[NSMutableArray alloc] initWithCapacity:1000];
    NSMutableArray *arrayFiles = [[NSMutableArray alloc] initWithCapacity:1000];
    
    //fill collections
    for (FMPanelListItem *listItem in listItems)
    {
        if (listItem.isDirectory)
        {
            [arrayDirs addObject:listItem];
        }
        else
        {
            [arrayFiles addObject:listItem];
        }
    }
    
    //sort collections
    [self sortPanelListItemsByName:arrayDirs];
    [self sortPanelListItemsByName:arrayFiles];
    
    //merge items
    _listItems = [[NSMutableArray alloc] init];

    //create directory up action ".." item for child folder
    if (parentDirectory != nil)
    {
        [parentDirectory setItemTypeDirUp];
        
        [_listItems addObject:parentDirectory];
    }
    
    [_listItems addObjectsFromArray:arrayDirs];
    [_listItems addObjectsFromArray:arrayFiles];
}

- (void)sortPanelListItemsByName:(NSMutableArray *)itemsToSort
{
    [itemsToSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        FMPanelListItem *itemA = (FMPanelListItem *)obj1;
        FMPanelListItem *itemB = (FMPanelListItem *)obj2;

        return [itemA.fileName localizedStandardCompare:itemB.fileName];
    }];
}

- (BOOL)isLoadingData
{
    return false;
}

//returns only a directory name part of path previously entered
- (NSString *)getNameToSelect
{
    return @"";
}

//returns name to select on exit from provider, for example zip file name
- (NSString *)getInitNameToSelect
{
    return @"";
}

//returns full directory path for current directory
- (NSString *)getParentDirectory
{
    return nil;
}

- (NSMutableArray *)getListItems
{
    return _listItems;
}

- (NSString *)getVolumeNameForPath:(NSString *)path
{
    return @"";
}

- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path
{
    return 0;
}

- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path
{
    return 0;
}

- (NSString *)currentPathToResource
{
    NSString *path = [self getPathToResource:self.currentPath];
    
    if (path == nil)
    {
        return self.currentPath;
    }
    
    return path;
}

- (NSString *)getPathToResource:(NSString *)path
{
    NSArray *items = [path componentsSeparatedByString:@":"];
    
    if (items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

- (NSString *)getPathInResource:(NSString *)path
{
    NSArray *items = [path componentsSeparatedByString:@":"];
    
    if (items.count > 1)
    {
        return [items objectAtIndex:1];
    }
    
    return @"/";
}

- (BOOL)supportedOperationCommand:(FMCommandId)commandId withMode:(FMPanelMode)panelMode
{
    return [self.commandSupport isOperationCommand:commandId withMode:panelMode];
}

- (BOOL)isSelection
{
    NSMutableArray *items = [self getListItems];
    
    if (items == nil)
    {
        return NO;
    }
    
    for (FMPanelListItem *item in items)
    {
        if (item.isSelected)
            return YES;
    }
    
    return NO;
}

- (NSMutableArray *)getListItemsForOperation
{
    NSMutableArray *resultItems = [[NSMutableArray alloc] initWithCapacity:100];

    NSMutableArray *items = [self getListItems];

    if (items != nil)
    {
        for (FMPanelListItem *item in items)
        {
            if (item.isSelected)
            {
                [resultItems addObject:item];
            }
        }
    }
    
    //if no items explicitly selected, get highlighted one
    if (resultItems.count == 0)
    {
        FMDirectoryViewController *directory = [AppDelegate.this viewControllerForProvider:self];
        
        FMPanelListItem *listItem = [directory getHighlightedListItem];
        
        if (listItem != nil)
        {
            if (listItem.itemType == FMPanelListItemTypeDefault)
            {
                [resultItems addObject:listItem];
            }
        }
    }
    
    return resultItems;
}

//iterates through directory of listItem for operation and adds created fileItems to collection
- (void)addFileItemsTo:(NSMutableArray *)fileItems fromDirectoryItem:(FMPanelListItem *)listItem forOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem
{
}

//returns array of FMFileItem items created from selected FMPanelListItem's with recursive iteration inside folders
- (NSMutableArray *)createFileItemsForOperation:(FMFileOperation *)fileOperation withDeepIteration:(BOOL)isDeepIteration
{
    NSMutableArray *fileItems = [self createFileItemsForOperation:fileOperation withDeepIteration:isDeepIteration andTestBlock:^BOOL(FMFileItem *fileItem)
    {
        return YES;
    }];
    
    //check if operation canceled
    if (fileOperation.isCanceled)
    {
        //remove items for default operations
        [fileItems removeAllObjects];
    }
    
    return fileItems;
}

- (NSMutableArray *)createFileItemsForOperation:(FMFileOperation *)fileOperation withDeepIteration:(BOOL)isDeepIteration andTestBlock:(OnTestFileItem)onTestFileItem
{
    //operation file items
    NSMutableArray *fileItems = [[NSMutableArray alloc] initWithCapacity:1000];
    
    //convert panel list items to operation file items
    for (FMPanelListItem *listItem in fileOperation.inputListItems)
    {
        if (listItem.isDirectory)
        {
            //add parent directory
            FMFileItem *fileItem = [FMFileItem fromListItem:listItem];
            
            if (onTestFileItem(fileItem))
            {
                [fileItems addObject:fileItem];
            }
            
            if (isDeepIteration)
            {
                //add directory content
                [self addFileItemsTo:fileItems fromDirectoryItem:listItem forOperation:fileOperation andTestBlock:onTestFileItem];
            }
        }
        else
        {
            //add file
            FMFileItem *fileItem = [FMFileItem fromListItem:listItem];
            
            if (onTestFileItem(fileItem))
            {
                [fileItems addObject:fileItem];
            }
        }
        
        //check if operation canceled
        if (fileOperation.isCanceled)
        {
            break;
        }
    }

    //validation for some providers
    [self validateFileItems:fileItems forOperation:fileOperation];

    return fileItems;
}

- (void)validateFileItems:(NSMutableArray *)fileItems forOperation:(FMFileOperation *)fileOperation
{
    
}

- (int)filesCountForPath:(NSString *)directoryPath
{
    return 0;
}

- (NSMutableArray *)createFileItemsForPanelListItem:(FMPanelListItem *)listItem withOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem
{
    //operation file items
    NSMutableArray *fileItems = [[NSMutableArray alloc] initWithCapacity:1000];
    
    if (listItem.isDirectory)
    {
        //add directory content
        [self addFileItemsTo:fileItems fromDirectoryItem:listItem forOperation:fileOperation andTestBlock:onTestFileItem];
    }
    else
    {
        //add file
        FMFileItem *fileItem = [FMFileItem fromListItem:listItem];
        
        [fileItems addObject:fileItem];
    }
    
    //check if operation canceled
    if (fileOperation.isCanceled)
    {
        [fileItems removeAllObjects];
    }
    else
    {
        [self validateFileItems:fileItems forOperation:fileOperation];
    }
    
    return fileItems;
}

- (NSInputStream *)getInputStream:(NSString *)filePath;
{
    return nil;
}

- (NSOutputStream *)getOutputStream:(NSString *)filePath;
{
    return nil;
}

//creates target filename path for file from source (self) provider to target provider
- (NSString *)getTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    return nil;
}

- (NSString *)getRelativeTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    return nil;
}

- (FMFileItem *)fileNameToFileItem:(NSString *)filePath
{
    return nil;
}

- (BOOL)removeFile:(NSString *)filePath
{
    return NO;
}

- (BOOL)fileExists:(NSString *)filePath
{
    return NO;
}

- (BOOL)directoryExists:(NSString *)directoryPath
{
    return NO;
}

- (BOOL)removeDirectory:(NSString *)filePath
{
    return NO;
}

- (BOOL)createDirectory:(NSString *)filePath
{
    return NO;
}

- (BOOL)renameFile:(NSString *)oldFilePath to:(NSString *)newFilePath
{
    return NO;
}

- (BOOL)moveFile:(NSString *)oldFilePath to:(NSString *)newFilePath error:(NSError **)error
{
    return NO;
}

- (NSUInteger)posixPermissionsForPath:(NSString *)filePath
{
    return 0;
}

- (BOOL)setPosixPermissions:(NSUInteger)permissions forPath:(NSString *)filePath
{
    return NO;
}

- (BOOL)supportsContextMenu:(FMPanelListItem *)item
{
    return NO;
}

@end
