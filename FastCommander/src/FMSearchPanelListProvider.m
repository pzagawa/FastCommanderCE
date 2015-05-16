//
//  FMSearchPanelListProvider.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMSearchPanelListProvider.h"
#import "FMWorkDirectory.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMOperationCommandSupport.h"
#import "FMProviderFileItem.h"

@implementation FMSearchPanelListProvider
{
    BOOL _isLoadingData;
    NSMutableDictionary *_fileItemsCache;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.providerName = @"virtual filesystem";
        
        self.maximumSupportedFileSize = nil;
        
        self.sourceFileItems = [[NSMutableArray alloc] init];

        [self reset];
    }
    
    return self;
}

- (void)initCommandSupport:(FMOperationCommandSupport *)support
{
    [support set:FMCommandId_fileOperation_VIEW modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_EDIT modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_COPY modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_MOVE modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_DELETE modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_RENAME modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_FOLDER modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_COMPRESS modeSource:YES modeTarget:NO];
    [support set:FMCommandId_fileOperation_PERMISSIONS modeSource:NO modeTarget:NO];
    [support set:FMCommandId_fileOperation_SEARCH modeSource:NO modeTarget:NO];
}

- (void)reset
{
    [super reset];
 
    _isLoadingData = NO;
    
    _fileItemsCache = [NSMutableDictionary dictionaryWithCapacity:2000];
}

//path format:
//resource:directory, for example:
//SEARCH FILES:*.txt, *.srt
- (BOOL)isPathValid:(NSString *)path
{
    NSString *resource = [self getPathToResource:path];
    //NSString *directory = [self getPathInResource:path];

    if ([resource isEqualToString:@"SEARCH"])
    {
        return YES;
    }

    return NO;
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

    NSMutableArray *listItems = [[NSMutableArray alloc] initWithCapacity:1000];

    //iterate generated file items
    for (FMFileItem *fileItem in self.sourceFileItems)
    {
        NSURL *url = [NSURL fileURLWithPath:fileItem.filePath];
        
        FMPanelListItem *listItem = [[FMPanelListItem alloc] initWithURL:url itemType:FMPanelListItemTypeDefault];

        [listItems addObject:listItem];
        
        [_fileItemsCache setValue:fileItem forKey:[fileItem.filePath copy]];
    }
    
    NSURL *parentUrl = [NSURL fileURLWithPath:self.basePath isDirectory:YES];
    
    FMPanelListItem *parentListItem = [[FMPanelListItem alloc] initWithURL:parentUrl itemType:FMPanelListItemTypeDirUp];
    
    [self sortedPanelListFromPanelListItems:listItems parentDirectory:parentListItem];
}

- (BOOL)isLoadingData
{
    return _isLoadingData;
}

- (NSString *)getNameToSelect
{
    return @"";
}

- (NSString *)getInitNameToSelect
{
    //no need to select list item after switch from this panel
    return @"";
}

- (NSString *)getParentDirectory
{
    NSString *resource = [self.basePath copy];
    
    return resource;
}

- (NSString *)getVolumeNameForPath:(NSString *)path
{
    return @"SEARCH RESULT";
}

- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path
{
    return 0;
}

- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path
{
    return 0;
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
    return 0;
}

- (NSInputStream *)getInputStream:(NSString *)filePath
{
    NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    
    return stream;
}

- (NSOutputStream *)getOutputStream:(NSString *)filePath
{
    //not supported
    return nil;
}

- (NSString *)getTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath
{
    NSString *targetFilePath = nil;

    NSString *sourcePath = [fileItem.filePath stringByDeletingLastPathComponent];

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
    
    NSString *sourcePath = [fileItem.filePath stringByDeletingLastPathComponent];
    
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

@end
