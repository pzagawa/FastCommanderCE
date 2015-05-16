//
//  FMZipPanelListProvider.m
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "zipzap.h"
#import "FMZipPanelListProvider.h"
#import "FMWorkDirectory.h"
#import "FMTheme.h"
#import "FMThemeManager.h"
#import "NSString+Utils.h"
#import "FMProviderFileItem.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMFileFilter.h"
#import "FMOperationCommandSupport.h"

@implementation FMZipPanelListProvider
{
    ZZArchive *_archive;
    FMFileItem *_archiveFileItem;
    id _archiveVolumeId;
    NSMutableArray *_providerFileItems;
    NSMutableDictionary *_providerFileItemsCache;
    BOOL _isLoadingData;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.providerName = @"zip file";
    
        self.maximumSupportedFileSize = nil;
        
        [self reset];
    }
    
    return self;
}

- (void)initCommandSupport:(FMOperationCommandSupport *)support
{
    [support set:FMCommandId_fileOperation_VIEW modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_EDIT modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_COPY modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_MOVE modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_DELETE modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_RENAME modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_FOLDER modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_COMPRESS modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_PERMISSIONS modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_SEARCH modeSource:NO modeTarget:NO];
}

- (void)reset
{
    [super reset];
    
    _isLoadingData = NO;

    _archive = nil;
    
    _providerFileItems = [[NSMutableArray alloc] initWithCapacity:2000];
    _providerFileItemsCache = [NSMutableDictionary dictionaryWithCapacity:2000];
}

//path format:
//resource:directory, for example:
//Users/guest/file.zip:/zip_directory
- (BOOL)isPathValid:(NSString *)path
{
    NSString *resource = [self getPathToResource:path];

    if (resource != nil)
    {
        //create file URL
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:resource isDirectory:NO];

        FMPanelListItem *listItem = [[FMPanelListItem alloc] initWithURL:fileUrl itemType:FMPanelListItemTypeDefault];
        
        if (listItem.isArchive == NO)
        {
            return NO;
        }
        
        //check if zip file accessible
        NSError *err;
        if ([fileUrl checkResourceIsReachableAndReturnError:&err] == YES)
        {
            NSString *inResourcePath = [self getPathInResource:path];
            
            //archive closed, allow open
            if (_providerFileItems.count == 0)
            {
                return YES;
            }
            else
            {
                //archive opened, allow request for root path
                if ([inResourcePath isEqualToString:@"/"])
                {
                    return YES;
                }
                
                //archive opened, verify request path
                for (FMProviderFileItem *fileItem in _providerFileItems)
                {
                    if ([fileItem.filePath isEqualToString:inResourcePath])
                    {
                        if (fileItem.isDirectory)
                        {
                            return YES;
                        }
                        else
                        {
                            return NO;
                        }
                    }
                }
                
                return NO;
            }
        }
    }
    
    return NO;
}

- (BOOL)currentPathContentChanged
{
    return NO;
}

- (void)resetPathContentChanged
{
}

- (void)reload
{
    [super reload];
    
    _isLoadingData = YES;
    
    @try
    {
        [self reload:self.currentPath];
    }
    @finally
    {
        _isLoadingData = NO;
    }
}

- (void)reload:(NSString *)path
{
    [super reload:path];
    
    //open archive
    if (_archive == nil)
    {
        NSURL *archiveFileUrl = [NSURL fileURLWithPath:self.basePath];
        
        _archiveFileItem = [FMFileItem fromUrl:archiveFileUrl];
        
        _archive = [ZZArchive archiveWithContentsOfURL:archiveFileUrl];
        
        //create file items collection with directories items from archive entries
        [self createProviderFileItems];
        
        //cache file items for fast lookup by filePath
        [self cacheProviderFileItems];
    }

    NSString *resource = [self getPathToResource:path];
    NSString *directory = [self getPathInResource:path];
    
    FMFileFilter *fileFilter = [[FMFileFilter alloc] initWithDirectory:directory];
    
    NSMutableArray *archiveListItems = [[NSMutableArray alloc] initWithCapacity:1000];

    FMProviderFileItem *parentFileItem = nil;

    //iterate generated file items
    for (FMProviderFileItem *fileItem in _providerFileItems)
    {
        //get parent file item
        if (parentFileItem == nil)
        {
            if ([fileItem.filePath isEqualToString:directory])
            {
                parentFileItem = fileItem;
            }
        }
        
        //filter archive entry items for loading current directory
        if ([fileFilter isFirstLevelFile:fileItem.filePath])
        {
            NSString *fullFileItemPath = [NSString stringWithFormat:@"%@:%@", resource, fileItem.filePath];

            FMPanelListItem *listItem = [[FMPanelListItem alloc] initWithResource:fullFileItemPath providerFileItem:fileItem itemType:FMPanelListItemTypeDefault];
            
            [archiveListItems addObject:listItem];
        }        
    }
    
    FMPanelListItem *parentListItem = [self getParentDirectoryListItem:path fileItem:parentFileItem];
    
    [self sortedPanelListFromPanelListItems:archiveListItems parentDirectory:parentListItem];
}

- (FMPanelListItem *)getParentDirectoryListItem:(NSString *)path fileItem:(FMProviderFileItem *)fileItem
{
    NSString *resource = [self getPathToResource:path];
    NSString *directory = [self getPathInResource:path];

    FMPanelListItem *parentListItem = nil;
     
    //if root load path
    if ([directory isEqualToString:@"/"])
    {
        //get zip file as parent directory
        parentListItem = [[FMPanelListItem alloc] initWithURL:[NSURL fileURLWithPath:resource isDirectory:YES] itemType:FMPanelListItemTypeDirUp];
    }
    else
    {
        //get archive entry as parent directory
        parentListItem = [[FMPanelListItem alloc] initWithResource:path providerFileItem:fileItem itemType:FMPanelListItemTypeDirUp];
    }

    [parentListItem setItemTypeDirUp];
    
    return parentListItem;
}

- (void)createProviderFileItems
{
    NSMutableDictionary *directoryCache = [NSMutableDictionary dictionaryWithCapacity:500];
    
    _providerFileItems = [[NSMutableArray alloc] initWithCapacity:2000];
    
    //first, collect directories entries from archive
    for (ZZArchiveEntry *archiveEntry in _archive.entries)
    {
        NSString *entryFileName = archiveEntry.fileName;
        
        if (entryFileName != nil)
        {
            BOOL isDirectory = [entryFileName hasSuffix:@"/"];

            if (isDirectory == YES)
            {
                //add directory item
                FMProviderFileItem *fileItem = [[FMProviderFileItem alloc] initWithArchiveEntry:archiveEntry];
                
                fileItem.volumeId = [_archiveFileItem.volumeId copy];
                
                [_providerFileItems addObject:fileItem];
                
                //cache directory item
                [directoryCache setValue:fileItem forKey:fileItem.filePath];
            }
        }
    }
 
    //second, scan all files entries, and parse directories from filenames
    for (ZZArchiveEntry *archiveEntry in _archive.entries)
    {
        NSString *entryFileName = archiveEntry.fileName;
        
        if (entryFileName != nil)
        {
            BOOL isDirectory = [entryFileName hasSuffix:@"/"];
            
            //process file entry
            if (isDirectory == NO)
            {
                //add file item
                FMProviderFileItem *fileItem = [[FMProviderFileItem alloc] initWithArchiveEntry:archiveEntry];
                
                fileItem.volumeId = [_archiveFileItem.volumeId copy];
                
                [_providerFileItems addObject:fileItem];
                
                //add directories items and cache them
                [self addProviderDirectoryItem:fileItem withCache:directoryCache];
            }
        }
    }
}

- (void)addProviderDirectoryItem:(FMProviderFileItem *)fileItem withCache:(NSMutableDictionary *)directoryCache
{
    NSString *filePath = [fileItem.filePath stringByDeletingLastPathComponent];

    if ([filePath isEqualToString:@"/"] == NO)
    {
        NSArray *pathComponents = [[filePath stringByDeletingSlashPrefix] componentsSeparatedByString:@"/"];
        
        NSMutableString *directory = [[NSMutableString alloc] initWithCapacity:16];

        for (NSString *pathItem in pathComponents)
        {
            [directory appendString:@"/"];
            [directory appendString:pathItem];

            NSString *directoryKey = [directory copy];
            
            //if directory item not already stored, create one
            if ([directoryCache objectForKey:directoryKey] == nil)
            {
                FMProviderFileItem *directoryItem = [[FMProviderFileItem alloc] initDirectoryItem:fileItem withPath:directoryKey];
                
                //add directory item to collection
                [_providerFileItems addObject:directoryItem];
                
                //cache directory item
                [directoryCache setValue:directoryItem forKey:directoryItem.filePath];
            }
        }
    }
}

- (void)cacheProviderFileItems
{
    for (FMProviderFileItem *providerFileItem in _providerFileItems)
    {
        [_providerFileItemsCache setValue:providerFileItem forKey:[providerFileItem.filePath copy]];
    }
}

- (FMProviderFileItem *)getProviderFileItemByFilePath:(NSString *)filePath
{
    if ([_providerFileItemsCache objectForKey:filePath] == nil)
    {
        return nil;
    }
    
    return [_providerFileItemsCache valueForKey:filePath];
}

- (BOOL)isLoadingData
{
    return _isLoadingData;
}

- (NSString *)getInitNameToSelect
{
    NSString *directory = [self getPathInResource:self.currentPath];
    
    //name to select as zip file name
    if ([directory isEqualToString:@"/"])
    {
        return [self.basePath lastPathComponent];
    }
    
    return nil;
}

- (NSString *)getNameToSelect
{
    NSString *zipDirectoryPrevious = [self getPathInResource:self.previousPath];
    NSString *zipDirectoryCurrent = [self getPathInResource:self.currentPath];
    
    return [FMWorkDirectory getPreviousName:zipDirectoryPrevious currPath:zipDirectoryCurrent];
}

- (NSString *)getParentDirectory
{
    NSString *resource = [self.basePath copy];
    NSString *directory = [self getPathInResource:self.currentPath];
  
    if ([directory isEqualToString:@"/"])
    {
        return [resource stringByDeletingLastPathComponent];
    }
    else
    {
        directory = [directory stringByDeletingLastPathComponent];

        if ([directory isEqualToString:@"/"])
        {
            return resource;
        }
        else
        {
            return [NSString stringWithFormat:@"%@:%@", resource, directory];
        }
    }
}

- (NSString *)getVolumeNameForPath:(NSString *)path
{
    return [self.basePath lastPathComponent];
}

- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path
{
    long long totalSize = 0;
    
    for (FMProviderFileItem *fileItem in _providerFileItems)
    {
        if (fileItem.isDirectory == NO)
        {
            totalSize += fileItem.fileSize;
        }
    }
    
    //uncompressed size
    return [NSNumber numberWithLongLong:totalSize];
}

- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path
{
    long long totalSize = [[self getVolumeTotalSizeForPath:nil] longLongValue];
    long long compressedSize = 0;
    
    NSURL *url = [NSURL fileURLWithPath:self.basePath isDirectory:NO];
    
    NSError *error = nil;
    NSNumber *fileSize = nil;
    
    if ([url getResourceValue: &fileSize forKey: NSURLFileSizeKey error: &error])
    {
        compressedSize = fileSize.longLongValue;
    }

    long long delta = totalSize - compressedSize;
    
    if (delta < 0)
    {
        delta = 0;
    }
    
    //compression ratio
    return [NSNumber numberWithLongLong:delta];
}

- (void)addFileItemsTo:(NSMutableArray *)fileItems fromDirectoryItem:(FMPanelListItem *)listItem forOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem
{
    NSString *directory = [self getPathInResource:listItem.resourcePath];

    FMFileFilter *fileFilter = [[FMFileFilter alloc] initWithDirectory:directory];
    
    for (FMProviderFileItem *providerFiletem in _providerFileItems)
    {
        if ([fileFilter isInsideFile:providerFiletem.filePath])
        {
            FMFileItem *fileItem = [FMFileItem fromProviderFileItem:providerFiletem];
            
            if (onTestFileItem(fileItem))
            {
                [fileItems addObject:fileItem];
            }
            
            //check if operation canceled
            if (fileOperation.isCanceled)
            {
                break;
            }
        }
    }
}

- (void)validateFileItems:(NSMutableArray *)fileItems forOperation:(FMFileOperation *)fileOperation
{
    for (FMFileItem *fileItem in fileItems)
    {
        //transform absolute paths to relative in-zip paths
        NSArray *filePathItems = [fileItem.filePath componentsSeparatedByString:@":"];
        
        if (filePathItems.count > 1)
        {
            //get in-zip directory part of full local path
            [fileItem updatePath: [filePathItems objectAtIndex:1]];
        }
        
        //check if operation canceled
        if (fileOperation.isCanceled)
        {
            break;
        }
    }
}

- (int)filesCountForPath:(NSString *)directoryPath
{
    NSString *directory = [self getPathInResource:directoryPath];
    
    FMFileFilter *fileFilter = [[FMFileFilter alloc] initWithDirectory:directory];
    
    int filesCount = 0;
    
    for (FMProviderFileItem *providerFiletem in _providerFileItems)
    {
        if ([fileFilter isInsideFile:providerFiletem.filePath])
        {
            if (providerFiletem.isDirectory == NO)
            {
                filesCount++;
            }
        }
    }
    
    return filesCount;
}

- (NSInputStream *)getInputStream:(NSString *)filePath
{
    FMProviderFileItem *providerFileItem = [self getProviderFileItemByFilePath:filePath];

    if (providerFileItem == nil)
    {
        return nil;
    }
    
    return providerFileItem.archiveEntry.stream;
}

- (NSOutputStream *)getOutputStream:(NSString *)filePath
{
    //not supported
    return nil;
}

- (NSString *)getTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    NSString *targetFilePath = nil;
    
    NSString *sourcePath = self.currentPath;

    NSString *directory = [self getPathInResource:sourcePath];

    NSRange range = [fileItem.filePath rangeOfString:directory];
    
    if (range.location != NSNotFound)
    {
        if (range.location == 0)
        {
            NSString *sourceRelativePath = [fileItem.filePath substringFromIndex:range.length];
            
            targetFilePath = [targetPath stringByAppendingPathComponent:sourceRelativePath];
        }
    }
    
    return targetFilePath;
}

- (NSString *)getRelativeTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    NSString *targetFilePath = nil;
    
    NSString *sourcePath = self.currentPath;
    
    NSString *directory = [self getPathInResource:sourcePath];
    
    NSRange range = [fileItem.filePath rangeOfString:directory];
    
    if (range.location != NSNotFound)
    {
        if (range.location == 0)
        {
            targetFilePath = [fileItem.filePath substringFromIndex:range.length];
        }
    }
    
    return targetFilePath;
}

- (FMFileItem *)fileNameToFileItem:(NSString *)filePath
{
    FMProviderFileItem *providerFileItem = [self getProviderFileItemByFilePath:filePath];
    
    if (providerFileItem == nil)
    {
        return nil;
    }
    
    return [FMFileItem fromProviderFileItem:providerFileItem];
}

- (BOOL)removeFile:(NSString *)filePath
{
    //not supported
    return NO;
}

- (BOOL)fileExists:(NSString *)filePath
{
    FMProviderFileItem *providerFileItem = [self getProviderFileItemByFilePath:filePath];
    
    if (providerFileItem == nil)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)directoryExists:(NSString *)directoryPath
{
    FMProviderFileItem *providerFileItem = [self getProviderFileItemByFilePath:directoryPath];
    
    if (providerFileItem == nil)
    {
        return NO;
    }
    
    return YES;    
}

- (BOOL)removeDirectory:(NSString *)filePath
{
    //not supported
    return NO;
}

- (BOOL)createDirectory:(NSString *)filePath
{
    //not supported
    return NO;
}

- (BOOL)renameFile:(NSString *)oldFilePath to:(NSString *)newFilePath
{
    //not supported
    return NO;
}

- (BOOL)moveFile:(NSString *)oldFilePath to:(NSString *)newFilePath error:(NSError **)error
{
    //not supported
    return NO;
}

- (NSUInteger)posixPermissionsForPath:(NSString *)filePath
{
    //not supported
    return 0;
}

- (BOOL)setPosixPermissions:(NSUInteger)permissions forPath:(NSString *)filePath
{
    //not supported
    return NO;
}

@end
