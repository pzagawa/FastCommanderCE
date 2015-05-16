//
//  PanelListItem.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPanelListItem.h"
#import "fnmatch.h"
#import "NSString+Utils.h"
#import "FMProviderFileItem.h"

@implementation FMPanelListItem

- (id)initWithURL:(NSURL *)value itemType:(FMPanelListItemType)itemType;
{
    self = [super init];
    
    if (self)
    {
        NSError *_error = nil;

        self->_itemType = itemType;
        self->_url = [value copy];
        self->_resourcePath = nil;

        NSString *_valueFileName = nil;
        NSNumber *_valueFileSize = nil;
        NSDate *_valueModificationDate = nil;
        id _valueVolumeId = nil;

        NSNumber *_valueIsDirectory = nil;
        NSNumber *_valueIsSymbolicLink = nil;
        NSNumber *_valueIsReadable = nil;
        NSNumber *_valueIsWritable = nil;
        NSNumber *_valueIsExecutable = nil;
        NSNumber *_valueIsHidden = nil;
        
        [self.url getResourceValue: &_valueFileName forKey: NSURLNameKey error: &_error];
        [self.url getResourceValue: &_valueFileSize forKey: NSURLFileSizeKey error: &_error];
        [self.url getResourceValue: &_valueModificationDate forKey: NSURLContentModificationDateKey error: &_error];
        [self.url getResourceValue: &_valueVolumeId forKey: NSURLVolumeIdentifierKey error: &_error];

        [self.url getResourceValue: &_valueIsDirectory forKey: NSURLIsDirectoryKey error: &_error];
        [self.url getResourceValue: &_valueIsSymbolicLink forKey: NSURLIsSymbolicLinkKey error: &_error];
        [self.url getResourceValue: &_valueIsReadable forKey: NSURLIsReadableKey error: &_error];
        [self.url getResourceValue: &_valueIsWritable forKey: NSURLIsWritableKey error: &_error];
        [self.url getResourceValue: &_valueIsExecutable forKey: NSURLIsExecutableKey error: &_error];
        [self.url getResourceValue: &_valueIsHidden forKey: NSURLIsHiddenKey error: &_error];
        
        self->_isSelected = NO;
        
        self->_fileName = _valueFileName;
        self->_fileExtension = self.fileName.pathExtensionLowerCase;
        self->_fileSize = _valueFileSize;
        self->_modificationDate = _valueModificationDate;
        self->_volumeId = _valueVolumeId;

        self->_isDirectory = (_valueIsDirectory.integerValue == 1);
        self->_isSymbolicLink = (_valueIsSymbolicLink.integerValue == 1);
        self->_isReadable = (_valueIsReadable.integerValue == 1);
        self->_isWritable = (_valueIsWritable.integerValue == 1);
        self->_isExecutable = (_valueIsExecutable.integerValue == 1);
        self->_isHidden = (_valueIsHidden.integerValue == 1);

        self->_isArchive = [self resolveIsArchive:self.fileExtension];
        self->_isDirectorySize = NO;
    }
    
    return self;
}

- (id)initWithResource:(NSString *)value providerFileItem:(FMProviderFileItem *)providerFileItem itemType:(FMPanelListItemType)itemType
{
    self = [super init];
    
    if (self)
    {
        self->_itemType = itemType;
        self->_url = nil;
        self->_resourcePath = [value copy];
        self->_isSelected = NO;
        
        self->_fileName = [value lastPathComponent];
        self->_fileExtension = self.fileName.pathExtensionLowerCase;
        self->_fileSize = [[NSNumber alloc] initWithLongLong:providerFileItem.fileSize];
        self->_modificationDate = providerFileItem.modificationDate;
        self->_volumeId = [providerFileItem.volumeId copy];

        self->_isDirectory = providerFileItem.isDirectory;
        self->_isSymbolicLink = providerFileItem.isSymbolicLink;
        self->_isReadable = YES;
        self->_isWritable = NO;
        self->_isExecutable = NO;
        self->_isHidden = providerFileItem.isHidden;

        self->_isArchive = [self resolveIsArchive:self.fileExtension];
        self->_isDirectorySize = NO;
    }
    
    return self;    
}

- (BOOL)isLooksBetterHidden
{
    //check based on extension
    if (self->_fileExtension != nil)
    {
        //rule for Chrome .crdownload extension
        if (self->_fileExtension.length == 10)
        {
            if ([self->_fileExtension isEqualToString:@"crdownload"])
            {
                return YES;
            }
        }
    }

    //rule for __MACOSX directory name
    if (self.isDirectory)
    {
        if (self->_fileName.length == 8)
        {
            if ([self->_fileName isEqualToString:@"__MACOSX"])
            {
                return YES;
            }
        }
    }

    //rule for Safari download extension
    if (self.isDirectory)
    {
        if (self->_fileExtension.length == 8)
        {
            if ([self->_fileExtension isEqualToString:@"download"])
            {
                return YES;
            }
        }
    }

    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    FMPanelListItem *newObject = [[[self class] alloc] init];
    
    if (newObject)
    {
        newObject->_itemType = self.itemType;
        newObject->_url = [self.url copyWithZone:zone];
        newObject->_resourcePath = [self.resourcePath copyWithZone:zone];
        newObject->_isSelected = self.isSelected;
        
        newObject->_fileName = [self.fileName copyWithZone:zone];
        newObject->_fileExtension = [self.fileExtension copyWithZone:zone];
        newObject->_fileSize = [self.fileSize copyWithZone:zone];
        newObject->_modificationDate = [self.modificationDate copyWithZone:zone];
        newObject->_volumeId = [self.volumeId copyWithZone:zone];
        
        newObject->_isDirectory = self.isDirectory;
        newObject->_isSymbolicLink = self.isSymbolicLink;
        newObject->_isReadable = self.isReadable;
        newObject->_isWritable = self.isWritable;
        newObject->_isExecutable = self.isExecutable;
        newObject->_isHidden = self.isHidden;
        
        newObject->_isArchive = self.isArchive;
        newObject->_isDirectorySize = self.isDirectorySize;
    }
    
    return newObject;
}

- (BOOL)resolveIsArchive:(NSString *)extension
{
    if ([extension isEqual:@"zip"])
        return YES;

    if ([extension isEqual:@"jar"])
        return YES;

    if ([extension isEqual:@"war"])
        return YES;

    return NO;
}

- (NSString *)unifiedFilePath
{
    if (self->_url == nil)
    {
        return self->_resourcePath;
    }

    return self->_url.path;
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"%@|%@|%@|%@",
        self.displayFileName, self.fileSize, self.modificationDate, self.attributesText];
}

- (NSString *)displayFileName
{
    if (self.itemType == FMPanelListItemTypeDirUp)
    {
        return @"..";
    }
    
    return self.fileName;
}

- (NSMutableString *)attributesText
{
    NSMutableString *value = [[NSMutableString alloc] init];
    
    NSString *firstPos = @"-";
    
    if (self.isDirectory)
    {
        firstPos = @"D";
    }

    if (self.isSymbolicLink)
    {
        firstPos = @"L";
    }

    [value appendString:firstPos];
    
    [value appendString:self.isReadable ? @"R" : @"-"];
    [value appendString:self.isWritable ? @"W" : @"-"];
    [value appendString:self.isExecutable ? @"X" : @"-"];
    [value appendString:self.isHidden ? @"H" : @"-"];
    
    return value;
}

- (NSString *)fileSizeText
{
    if (self.isDirectory)
    {
        if (self.isDirectorySize)
        {
            return [NSByteCountFormatter stringFromByteCount:self.fileSize.longValue countStyle:NSByteCountFormatterCountStyleFile];
        }
        else
        {
            return @"<DIR>";
        }
    }
    
    return [NSByteCountFormatter stringFromByteCount:self.fileSize.longValue countStyle:NSByteCountFormatterCountStyleFile];
}

//many patterns separated by space
- (BOOL)isItemsSelectionMatch:(NSString *)pattern
{
    const char* cFileName = [self.displayFileName UTF8String];
    
    NSArray *items = [pattern componentsSeparatedByString:@" "];

    for (NSString *item in items)
    {
        NSString *newItem = [item copy];
        
        if ([item hasPrefix:@"*"] == NO)
        {
            newItem = [NSString stringWithFormat:@"*%@", newItem];
        }
        
        if ([item hasSuffix:@"*"] == NO)
        {
            newItem = [NSString stringWithFormat:@"%@*", newItem];
        }
        
        const char* cPattern = [newItem UTF8String];
        
        if (fnmatch(cPattern, cFileName, FNM_CASEFOLD) == 0)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)setItemTypeDirUp
{
    self->_itemType = FMPanelListItemTypeDirUp;
    
    self->_isDirectory = YES;
    self->_isArchive = NO;
}

- (void)setSelected:(BOOL)value
{
    self->_isSelected = value;
}

- (void)setDirectorySize:(long long)value
{
    self->_isDirectorySize = YES;
    self->_fileSize = [[NSNumber alloc] initWithLongLong:value];
}

- (NSString *)symbolicLinkPath
{
    if (self.isSymbolicLink)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        return [fileManager destinationOfSymbolicLinkAtPath:self.unifiedFilePath error:nil];
    }
    
    return nil;
}

@end
