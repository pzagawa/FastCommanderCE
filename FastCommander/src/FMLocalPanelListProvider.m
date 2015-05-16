//
//  FMLocalPanelListProvider.m
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMLocalPanelListProvider.h"
#import "FMFileManager.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMDirectoryWatcher.h"
#import "FMOperationCommandSupport.h"

@implementation FMLocalPanelListProvider
{
    FMFileManager *_fileManager;
    FMDirectoryWatcher *_watcher;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.providerName = @"local filesystem";

        _fileManager = [[FMFileManager alloc] init];
    }
    
    return self;
}

- (void)initCommandSupport:(FMOperationCommandSupport *)support
{
    [support set:FMCommandId_fileOperation_VIEW modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_EDIT modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_COPY modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_MOVE modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_DELETE modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_RENAME modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_FOLDER modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_COMPRESS modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_PERMISSIONS modeSource:YES modeTarget:YES];
    [support set:FMCommandId_fileOperation_SEARCH modeSource:YES modeTarget:YES];
}

- (void)reset
{
    [super reset];

    [_fileManager reset];
}

- (BOOL)isPathValid:(NSString *)path
{
    NSString *resource = [self getPathToResource:path];
    //NSString *directory = [self getPathInResource:path];
    
    if (resource != nil)
    {
        //create file URL
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:resource isDirectory:NO];
        
        if ([fileUrl isFileURL])
        {
            return NO;
        }
        
        NSError *err;
        
        //check if local file accessible
        if ([fileUrl checkResourceIsReachableAndReturnError:&err] == YES)
        {
            FMPanelListItem *listItem = [[FMPanelListItem alloc] initWithURL:fileUrl itemType:FMPanelListItemTypeDefault];
            
            if (listItem.isArchive == NO)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)currentPathContentChanged
{
    if (self->_watcher == nil)
    {
        return NO;
    }

    return self->_watcher.directoryContentChanged;
}

- (void)resetPathContentChanged
{
    if (self->_watcher != nil)
    {
        self->_watcher.directoryContentChanged = NO;
    }
}

- (void)reload
{
    [super reload];
    
    [_fileManager reload];

    NSString *directory = _fileManager.directory.directory.path;
    
    if ([FMWorkDirectory isRootDirectory:directory] == YES)
    {
        directory = nil;
    }
    
    [self sortedPanelListFromUrlItems:_fileManager.urlItems parentDirectory:directory];
    
    [self updateMaximumSupportedFileSize];
}

- (void)reload:(NSString *)path
{
    [super reload:path];
    
    [_fileManager reload:self.currentPath];
    
    self->_watcher = [[FMDirectoryWatcher alloc] initWithPath:path];
    
    NSString *directory = _fileManager.directory.directory.path;
    
    if ([FMWorkDirectory isRootDirectory:directory] == YES)
    {
        directory = nil;
    }
    
    [self sortedPanelListFromUrlItems:_fileManager.urlItems parentDirectory:directory];

    [self updateMaximumSupportedFileSize];
}


- (void)updateMaximumSupportedFileSize
{
    self.maximumSupportedFileSize = nil;

    NSURL *url = [NSURL fileURLWithPath:self.currentPath];
    
    NSError *error;
    NSString *name;
    
    if ([url getResourceValue:&name forKey:NSURLVolumeLocalizedFormatDescriptionKey error:&error])
    {
        if (name != nil)
        {
            //FAT32 file system detected
            if ([name isEqualToString:@"MS-DOS (FAT32)"])
            {
                name = nil;
                
                //set 4 gigabytes max file size
                self.maximumSupportedFileSize = [NSNumber numberWithUnsignedLongLong:4294967296];
            }
        }
    }
}

- (BOOL)isLoadingData
{
    return [_fileManager isLoadingData];
}

- (NSString *)getNameToSelect
{
    if (self.nameToSelect != nil)
    {
        NSString *name = [self.nameToSelect copy];
        
        self.nameToSelect = nil;
        
        return name;
    }
    
    return [FMWorkDirectory getPreviousName:self.previousPath currPath:self.currentPath];
}

- (NSString *)getInitNameToSelect
{
    return @"";
}

- (NSString *)getParentDirectory
{
    return [[_fileManager.directory getUpDirectory] path];
}

- (NSString *)getVolumeNameForPath:(NSString *)path
{
    return [_fileManager getVolumeNameForPath:path];
}

- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path
{
    return [_fileManager getVolumeTotalSizeForPath:path];
}

- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path
{
    return [_fileManager getVolumeAvailableSizeForPath:path];
}

- (void)addFileItemsTo:(NSMutableArray *)fileItems fromDirectoryItem:(FMPanelListItem *)listItem forOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //include url keys
    NSArray *properties = [NSArray arrayWithObjects:
                           NSURLNameKey,
                           NSURLFileSizeKey,
                           NSURLContentModificationDateKey,
                           NSURLIsDirectoryKey,
                           NSURLIsSymbolicLinkKey,
                           nil];
    
    //include hidden files
    NSDirectoryEnumerationOptions options = 0;
    
    //enumerator error handler
    BOOL (^errorHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error)
    {
        //continue enumeration in case of an error
        return YES;
    };
    
    //process
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:listItem.url includingPropertiesForKeys:properties options:options errorHandler:errorHandler];
    
    //enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator)
    {
        FMFileItem *fileItem = [FMFileItem fromUrl:theURL];
        
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

- (void)validateFileItems:(NSMutableArray *)fileItems forOperation:(FMFileOperation *)fileOperation
{
    
}

- (int)filesCountForPath:(NSString *)directoryPath
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //include url keys
    NSArray *properties = [NSArray arrayWithObjects:
                           NSURLIsDirectoryKey,
                           nil];
    
    //include hidden files
    NSDirectoryEnumerationOptions options = 0;
    
    //enumerator error handler
    BOOL (^errorHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error)
    {
        //continue enumeration in case of an error
        return YES;
    };
    
    //process
    NSURL *url = [NSURL fileURLWithPath:directoryPath];

    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:url includingPropertiesForKeys:properties options:options errorHandler:errorHandler];
    
    int filesCount = 0;

    NSError *error = nil;
    NSNumber *isDirectory = nil;
    
    //enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *itemUrl in dirEnumerator)
    {
        if ([itemUrl getResourceValue: &isDirectory forKey: NSURLIsDirectoryKey error: &error])
        {
            if (isDirectory.integerValue == 0)
            {
                filesCount++;
            }
        }
    }
    
    return filesCount;
}

- (NSInputStream *)getInputStream:(NSString *)filePath
{
    NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    
    return stream;
}

- (NSOutputStream *)getOutputStream:(NSString *)filePath
{
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    
    return stream;
}

- (NSString *)getTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    NSString *targetFilePath = nil;

    NSString *sourcePath = self.currentPath;

    NSRange range = [fileItem.filePath rangeOfString:sourcePath];

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
    
    NSRange range = [fileItem.filePath rangeOfString:sourcePath];
    
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
    return [FMFileItem fromFilePath:filePath];
}

- (BOOL)removeFile:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (self.isUseTrash)
    {
        return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
            source:[filePath stringByDeletingLastPathComponent]
            destination:@""
            files:[NSArray arrayWithObject:[filePath lastPathComponent]]
            tag:nil];
    }
    
    return [fm removeItemAtPath:filePath error:nil];
}

- (BOOL)fileExists:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
 
    return [fm fileExistsAtPath:filePath];
}

- (BOOL)directoryExists:(NSString *)directoryPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    return [fm fileExistsAtPath:directoryPath];
}

- (BOOL)removeDirectory:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    if (self.isUseTrash)
    {
        return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
            source:[filePath stringByDeletingLastPathComponent]
            destination:@""
            files:[NSArray arrayWithObject:[filePath lastPathComponent]]
            tag:nil];
    }

    return [fm removeItemAtPath:filePath error:nil];
}

- (BOOL)createDirectory:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    return [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)renameFile:(NSString *)oldFilePath to:(NSString *)newFilePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    return [fm moveItemAtPath:oldFilePath toPath:newFilePath error:nil];
}

- (BOOL)moveFile:(NSString *)oldFilePath to:(NSString *)newFilePath error:(NSError **)error
{
    NSFileManager *fm = [NSFileManager defaultManager];

    return [fm moveItemAtPath:oldFilePath toPath:newFilePath error:error];
}

- (NSUInteger)posixPermissionsForPath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSDictionary *map = [fm attributesOfItemAtPath:filePath error:nil];

    if (map != nil)
    {
        return map.filePosixPermissions;
    }

    return 0;
}

- (BOOL)setPosixPermissions:(NSUInteger)permissions forPath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSNumber *value = [NSNumber numberWithUnsignedInteger:permissions];

    NSDictionary *map = [NSDictionary dictionaryWithObject:value forKey:NSFilePosixPermissions];
    
    return [fm setAttributes:map ofItemAtPath:filePath error:nil];
}

- (BOOL)supportsContextMenu:(FMPanelListItem *)item
{
    if (item != nil)
    {
        if (item.itemType == FMPanelListItemTypeDefault)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
