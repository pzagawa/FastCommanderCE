//
//  FMProviderFileItem.m
//  FastCommander
//
//  Created by Piotr Zagawa on 10.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "zipzap.h"
#import "FMProviderFileItem.h"
#import "NSString+Utils.h"

@implementation FMProviderFileItem

- (id)initWithArchiveEntry:(ZZArchiveEntry *)entry
{
    self = [super init];
    
    if (self)
    {
        self->_archiveEntry = entry;
        
        self->_filePath = [[entry.fileName stringByAppendingSlashPrefix] stringByDeletingSlashSuffix];
        self->_fileSize = entry.uncompressedSize;
        self->_fileSizeCompressed = entry.compressedSize;
        self->_isDirectory = [entry.fileName hasSuffix:@"/"];
        self->_isSymbolicLink = NO;
    }
    
    return self;
}

- (id)initWithFileItem:(FMProviderFileItem *)item
{
    self = [super init];
    
    if (self)
    {
        self->_archiveEntry = item.archiveEntry;

        self->_filePath = [[item.filePath stringByAppendingSlashPrefix] stringByDeletingSlashSuffix];
        self->_fileSize = item.fileSize;
        self->_fileSizeCompressed = item.fileSizeCompressed;
        self->_isDirectory = [item.filePath hasSuffix:@"/"];
        self->_isSymbolicLink = item.isSymbolicLink;
        self->_volumeId = [item.volumeId copy];
    }
    
    return self;
}

- (id)initDirectoryItem:(FMProviderFileItem *)item withPath:(NSString *)path
{
    self = [super init];
    
    if (self)
    {
        self->_archiveEntry = item.archiveEntry;

        self->_filePath = [[path stringByAppendingSlashPrefix] stringByDeletingSlashSuffix];
        self->_fileSize = 0;
        self->_fileSizeCompressed = 0;
        self->_isDirectory = YES;
        self->_isSymbolicLink = NO;
        self->_volumeId = [item.volumeId copy];
    }
    
    return self;
}

- (NSDate *)modificationDate
{
    if (self->_archiveEntry != nil)
    {
        return [self->_archiveEntry.lastModified copy];
    }
    
    return [self.modificationDate copy];
}

- (BOOL)isHidden
{
    return [[self->_filePath lastPathComponent] hasPrefix:@"."];
}

- (NSString *)description
{
    return self.filePath;
}

@end
