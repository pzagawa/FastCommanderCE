//
//  FMProcessTargetFile.m
//  FastCommander
//
//  Created by Piotr Zagawa on 19.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMProcessTargetFile.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMCommand.h"

@implementation FMProcessTargetFile

- (id)initWithFileOperation:(FMFileCopyOperation *)fileOperation
{
    self = [super init];
    
    if (self)
    {
        self.fileOperation = fileOperation;        
    }
    
    return self;
}

- (NSString *)targetPathFor:(FMFileItem *)fileItem
{
    NSString *path = nil;
    
    //create target file path
    if (fileItem.targetFilePath == nil)
    {
        path = [self.fileOperation.sourceProvider getTargetFileName:fileItem withTargetPath:self.fileOperation.targetProvider.currentPath];
    }
    else
    {
        path = [fileItem.targetFilePath copy];
    }
    
    if (path == nil)
    {
        //can't create target file path
        [fileItem setStatus:FMFileItemStatus_TARGET_FILENAME_ERROR];
    }

    return path;
}

- (NSString *)createAndValidatePathForItem:(FMFileItem *)fileItem
{
    NSString *path = nil;
    
    if (fileItem.isDirectory)
    {
        path = [self createAndValidateDirectoryPath:fileItem];
    }
    else
    {
        path = [self createAndValidateFilePath:fileItem];
    }
    
    return path;
}

- (NSString *)createAndValidateFilePath:(FMFileItem *)fileItem
{
    NSString *targetFilePath = [self targetPathFor:fileItem];
        
    //get reference file item
    fileItem.referenceFileItem = [self.fileOperation.targetProvider fileNameToFileItem:targetFilePath];
    
    //check if source and target are equal
    if ([fileItem.filePath isEqualToString:targetFilePath])
    {
        //can't copy to itself
        [fileItem setStatus:FMFileItemStatus_SOURCE_TARGET_EQUAL_ERROR];
        return nil;
    }
    
    //check target file system support
    if (self.fileOperation.targetProvider.maximumSupportedFileSize != nil)
    {
        if (fileItem.fileSize > self.fileOperation.targetProvider.maximumSupportedFileSize.longLongValue)
        {
            //target file system does not support so big files
            [fileItem setStatus:FMFileItemStatus_TARGET_NOT_SUPPORTS_BIG_FILES];
            return nil;
        }
    }
    
    //create target directory
    NSString *targetDirectory = [targetFilePath stringByDeletingLastPathComponent];
    
    //check target file system free space for file bigger than 10MB
    if (fileItem.fileSize > (1024 * 1024 * 10))
    {
        NSNumber *availableSpace = [self.fileOperation.targetProvider getVolumeAvailableSizeForPath:targetDirectory];
        
        if (fileItem.fileSize > availableSpace.longLongValue)
        {
            //target file system does not have enough free space
            [fileItem setStatus:FMFileItemStatus_NOT_ENOUGH_SPACE_ON_TARGET];
            return nil;
        }
    }
    
    //check if target exists
    if ([self.fileOperation.targetProvider fileExists:targetFilePath])
    {
        //check SKIP action
        if (fileItem.userActionType == FMOperationUserActionType_SKIP)
        {
            [fileItem setStatus:FMFileItemStatus_TARGET_EXISTS_ERROR];
            return nil;
        }
        
        //check OVERWRITE action
        if (fileItem.userActionType == FMOperationUserActionType_OVERWRITE)
        {
            [fileItem setStatus:FMFileItemStatus_TODO];
            
            //continue
            //...
        }
    }
    
    //create target directory
    if ([self.fileOperation.targetProvider createDirectory:targetDirectory] == NO)
    {
        [fileItem setStatus:FMFileItemStatus_TARGET_DIRECTORY_ERROR];
        return nil;
    }
    
    return targetFilePath;
}

- (NSString *)createAndValidateDirectoryPath:(FMFileItem *)fileItem
{
    NSString *targetDirectoryPath = [self targetPathFor:fileItem];
    
    //create target directory
    if ([self.fileOperation.targetProvider createDirectory:targetDirectoryPath] == NO)
    {
        [fileItem setStatus:FMFileItemStatus_TARGET_DIRECTORY_ERROR];
        return nil;
    }
    
    return targetDirectoryPath;
}

@end
