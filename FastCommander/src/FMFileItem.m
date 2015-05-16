//
//  FMFileItem.m
//  FastCommander
//
//  Created by Piotr Zagawa on 03.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileItem.h"
#import "FMPanelListItem.h"
#import "FMPanelListProvider.h"
#import "FMProviderFileItem.h"
#import "NSString+Utils.h"

@implementation FMFileItem
{
    NSString *_statusDescription;
}

+ (FMFileItem *)fromListItem:(FMPanelListItem *)listItem
{
    FMFileItem *fileItem = [[FMFileItem alloc] init];
    
    fileItem->_filePath = [listItem.unifiedFilePath copy];
    fileItem->_fileSize = listItem.fileSize.longLongValue;
    fileItem->_modificationDate = [listItem.modificationDate copy];
    fileItem->_isDirectory = listItem.isDirectory;
    fileItem->_isSymbolicLink = listItem.isSymbolicLink;
    fileItem->_isHidden = listItem.isHidden;
    fileItem->_volumeId = [listItem.volumeId copy];
    fileItem->_status = FMFileItemStatus_TODO;

    fileItem->_userActionType = FMOperationUserActionType_SKIP;
    
    fileItem.targetFilePath = nil;
    fileItem.referenceFileItem = nil;

    return fileItem;
}

+ (FMFileItem *)fromUrl:(NSURL *)url
{
    FMFileItem *fileItem = [[FMFileItem alloc] init];

    NSError *_error = nil;
    
    NSNumber *_fileSize = nil;
    NSDate *_modificationDate = nil;
    NSNumber *_isDirectory = nil;
    NSNumber *_isSymbolicLink = nil;
    NSNumber *_isHidden = nil;
    id _valueVolumeId = nil;
    
    [url getResourceValue: &_fileSize forKey: NSURLFileSizeKey error: &_error];
    [url getResourceValue: &_modificationDate forKey: NSURLContentModificationDateKey error: &_error];
    [url getResourceValue: &_isDirectory forKey: NSURLIsDirectoryKey error: &_error];
    [url getResourceValue: &_isSymbolicLink forKey: NSURLIsSymbolicLinkKey error: &_error];
    [url getResourceValue: &_isHidden forKey: NSURLIsHiddenKey error: &_error];
    [url getResourceValue: &_valueVolumeId forKey: NSURLVolumeIdentifierKey error: &_error];
    
    fileItem->_filePath = [url.path copy];
    fileItem->_fileSize = _fileSize.longLongValue;
    fileItem->_modificationDate = _modificationDate;
    fileItem->_isDirectory = (_isDirectory.integerValue == 1);
    fileItem->_isSymbolicLink = (_isSymbolicLink.integerValue == 1);
    
    fileItem->_isHidden = (_isHidden.integerValue == 1);
    fileItem->_volumeId = _valueVolumeId;
    fileItem->_status = FMFileItemStatus_TODO;

    fileItem->_userActionType = FMOperationUserActionType_SKIP;
    
    fileItem.targetFilePath = nil;
    fileItem.referenceFileItem = nil;

    return fileItem;
}

+ (FMFileItem *)fromProviderFileItem:(FMProviderFileItem *)providerFileItem
{
    FMFileItem *fileItem = [[FMFileItem alloc] init];
    
    fileItem->_filePath = [providerFileItem.filePath copy];
    fileItem->_fileSize = providerFileItem.fileSize;
    fileItem->_isDirectory = providerFileItem.isDirectory;
    fileItem->_isSymbolicLink = providerFileItem.isSymbolicLink;
    fileItem->_isHidden = providerFileItem.isHidden;
    fileItem->_volumeId = [providerFileItem.volumeId copy];
    fileItem->_modificationDate = providerFileItem.modificationDate;
    fileItem->_status = FMFileItemStatus_TODO;
    
    fileItem->_userActionType = FMOperationUserActionType_SKIP;
    
    fileItem.targetFilePath = nil;
    fileItem.referenceFileItem = nil;
    
    return fileItem;
}

+ (FMFileItem *)fromFilePath:(NSString *)filePath
{
    FMFileItem *fileItem = [[FMFileItem alloc] init];

    NSURL *url = [NSURL fileURLWithPath:[filePath copy]];
    
    NSError *_error = nil;
    
    NSNumber *_fileSize = nil;
    NSDate *_modificationDate = nil;
    NSNumber *_isDirectory = nil;
    NSNumber *_isSymbolicLink = nil;
    NSNumber *_isHidden = nil;
    id _valueVolumeId = nil;
    
    if ([url getResourceValue: &_fileSize forKey: NSURLFileSizeKey error:&_error])
    {
        fileItem->_fileSize = _fileSize.longLongValue;        
    }
    else
    {
        fileItem->_fileSize = 0;
    }
    
    if ([url getResourceValue: &_modificationDate forKey: NSURLContentModificationDateKey error:&_error])
    {
        fileItem->_modificationDate = _modificationDate;
    }
    else
    {
        fileItem->_modificationDate = nil;
    }
    
    if ([url getResourceValue: &_isDirectory forKey: NSURLIsDirectoryKey error:&_error])
    {
        fileItem->_isDirectory = (_isDirectory.integerValue == 1);        
    }
    else
    {
        fileItem->_isDirectory = NO;
    }

    if ([url getResourceValue: &_isSymbolicLink forKey: NSURLIsSymbolicLinkKey error:&_error])
    {
        fileItem->_isSymbolicLink = (_isSymbolicLink.integerValue == 1);
    }
    else
    {
        fileItem->_isSymbolicLink = NO;
    }

    if ([url getResourceValue: &_isHidden forKey: NSURLIsHiddenKey error:&_error])
    {
        fileItem->_isHidden = (_isHidden.integerValue == 1);
    }
    else
    {
        fileItem->_isHidden = NO;
    }

    if ([url getResourceValue: &_valueVolumeId forKey: NSURLVolumeIdentifierKey error:&_error])
    {
        fileItem->_volumeId = _valueVolumeId;
    }
    else
    {
        fileItem->_volumeId = nil;
    }

    fileItem->_filePath = [filePath copy];
    fileItem->_status = FMFileItemStatus_TODO;
    
    fileItem->_userActionType = FMOperationUserActionType_SKIP;

    fileItem.targetFilePath = nil;
    fileItem.referenceFileItem = nil;

    return fileItem;
}

- (NSString *)fileName
{
    return [self.filePath lastPathComponent];
}

- (NSString *)fileSizeText
{
    return [NSByteCountFormatter stringFromByteCount:self.fileSize countStyle:NSByteCountFormatterCountStyleFile];
}

- (void)setAsFinished
{
    //mark item without an error as done
    if (self.status == FMFileItemStatus_TODO)
    {
        self->_status = FMFileItemStatus_DONE;
    }
}

- (void)setStatus:(FMFileItemStatus)status
{
    self->_status = status;
    self->_statusDescription = nil;
}

- (void)setStatus:(FMFileItemStatus)status withError:(NSError *)error
{
    self->_status = status;
    self->_statusDescription = [error.localizedDescription copy];
}

- (void)setStatus:(FMFileItemStatus)status withException:(NSException *)exception
{
    self->_status = status;
    self->_statusDescription = [exception.description copy];
}

- (void)updatePath:(NSString *)path
{
    self->_filePath = path;
}

- (BOOL)isError
{
    if (self.status < 0)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isCanceled
{
    if (self.status == FMFileItemStatus_CANCELED)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isDone
{
    if (self.status == FMFileItemStatus_DONE)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isTargetExists
{
    if (self.status == FMFileItemStatus_TARGET_EXISTS_ERROR)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isTheSameVolume:(FMFileItem *)fileItem
{
    if (self.volumeId == nil)
        return NO;

    if (fileItem.volumeId == nil)
        return NO;
    
    return [self.volumeId isEqual:fileItem.volumeId];
}

- (NSString *)statusAsText
{
    switch (self.status)
    {
        case FMFileItemStatus_SOURCE_MOVE_ERROR:
            return @"File move error.";
        case FMFileItemStatus_NOT_ENOUGH_SPACE_ON_TARGET:
            return @"Target filesystem does not have enough free space.";
        case FMFileItemStatus_TARGET_NOT_SUPPORTS_BIG_FILES:
            return @"Target filesystem does not support big files.";            
        case FMFileItemStatus_SOURCE_REMOVE_ERROR:
            return @"Source file delete error.";
        case FMFileItemStatus_TARGET_DIRECTORY_ERROR:
            return @"Target directory test error.";
        case FMFileItemStatus_SOURCE_TARGET_EQUAL_ERROR:
            return @"File can't be copied on itself.";
        case FMFileItemStatus_TARGET_EXISTS_ERROR:
            return @"Target file already exists.";
        case FMFileItemStatus_TARGET_FILENAME_ERROR:
            return @"Target filename test error.";
        case FMFileItemStatus_READ_ERROR:
            return @"File read error.";
        case FMFileItemStatus_WRITE_ERROR:
            return @"File write error.";
        case FMFileItemStatus_INPUT_OPEN_ERROR:
            return @"Source file open error.";
        case FMFileItemStatus_OUTPUT_OPEN_ERROR:
            return @"Target file open error.";
        case FMFileItemStatus_ERROR:
            return @"Error.";
        case FMFileItemStatus_TODO:
            return @"";
        case FMFileItemStatus_DONE:
            return @"";
        case FMFileItemStatus_CANCELED:
            return @"Canceled.";
    }
    
    return @"";
}

- (NSString *)statusText
{
    NSMutableString *text = [[NSMutableString alloc] init];
    
    [text appendString:self.statusAsText];
    
    if (self->_statusDescription != nil)
    {
        [text appendString:@". "];
        [text appendString:self->_statusDescription];
    }
    
    return text;
}

- (FMFileViewType)fileViewType
{
    NSString *fileExtension = self.filePath.pathExtensionLowerCase;
    
    NSArray *imageTypes = [NSImage imageFileTypes];
    
    for (NSString *imageType in imageTypes)
    {
        NSString *value = [imageType lowercaseString];
        
        if ([value isEqualToString:fileExtension])
        {
            return FMFileViewType_IMAGE;
        }
    }
    
    return FMFileViewType_TEXT;
}

@end
