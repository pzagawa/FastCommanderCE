//
//  FMFileFilter.m
//  FastCommander
//
//  Created by Piotr Zagawa on 12.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileFilter.h"
#import "NSString+Utils.h"

@implementation FMFileFilter
{
    NSString *_directoryPath;
    BOOL _isRootDirectory;
    NSString *_normalizedDirectoryPath;
    NSArray *_directoryPathParts;
}

- (id)initWithDirectory:(NSString *)directoryPath
{
    self = [super init];
    
    if (self)
    {
        self->_directoryPath = [directoryPath copy];
        self->_isRootDirectory = ([_directoryPath isEqualToString:@"/"]);
        self->_normalizedDirectoryPath = [[_directoryPath stringByDeletingSlashPrefix] stringByDeletingSlashSuffix];
        self->_directoryPathParts = [_normalizedDirectoryPath componentsSeparatedByString:@"/"];
    }
    
    return self;
}

- (BOOL)isFirstLevelFile:(NSString *)filePath
{
    NSString *normalizedFilePath = [[filePath stringByDeletingSlashPrefix] stringByDeletingSlashSuffix];
    
    NSArray *filePathParts = [normalizedFilePath componentsSeparatedByString:@"/"];
    
    //condition if request directory is root
    if (_isRootDirectory)
    {
        //accept only root/level1 path items
        if (filePathParts.count == 1)
        {
            return YES;
        }
    }
        
    //exclude file equal loading/parent directory
    if ([normalizedFilePath isEqualToString:_normalizedDirectoryPath])
    {
        return NO;
    }
        
    //compare both paths by components
    return [self isFirstLevelFile:filePathParts inDirectory:_directoryPathParts];
}

- (BOOL)isFirstLevelFile:(NSArray *)fileParts inDirectory:(NSArray *)directoryParts
{
    //compare both paths prefix equality
    int equalityCounter = 0;
    
    //iterate components of both paths
    for (int index = 0; index < directoryParts.count; index++)
    {
        NSString *directoryPart = nil;
        NSString *itemPathPart = nil;
        
        //get directory part string
        if (index < directoryParts.count)
        {
            directoryPart = directoryParts[index];
        }
        
        //get file part string
        if (index < fileParts.count)
        {
            itemPathPart = fileParts[index];
        }
        
        //compare both parts
        if ((directoryPart != nil) && (itemPathPart != nil))
        {
            if ([directoryPart isEqualToString:itemPathPart])
            {
                equalityCounter++;
            }
        }
    }
    
    //accept only items with equal path components
    if (equalityCounter == directoryParts.count)
    {
        //and items with paths within directory
        if (fileParts.count == (directoryParts.count + 1))
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isInsideFile:(NSString *)filePath
{
    NSString *normalizedFilePath = [[filePath stringByDeletingSlashPrefix] stringByDeletingSlashSuffix];
    
    NSArray *filePathParts = [normalizedFilePath componentsSeparatedByString:@"/"];
    
    //exclude file equal loading/parent directory
    if ([normalizedFilePath isEqualToString:_normalizedDirectoryPath])
    {
        return NO;
    }

    //compare both paths by components
    return [self isInsideFile:filePathParts inDirectory:_directoryPathParts];
}

- (BOOL)isInsideFile:(NSArray *)fileParts inDirectory:(NSArray *)directoryParts
{
    //compare both paths prefix equality
    int equalityCounter = 0;
    
    //iterate components of both paths
    for (int index = 0; index < directoryParts.count; index++)
    {
        NSString *directoryPart = nil;
        NSString *itemPathPart = nil;
        
        //get directory part string
        if (index < directoryParts.count)
        {
            directoryPart = directoryParts[index];
        }
        
        //get file part string
        if (index < fileParts.count)
        {
            itemPathPart = fileParts[index];
        }
        
        //compare both parts
        if ((directoryPart != nil) && (itemPathPart != nil))
        {
            if ([directoryPart isEqualToString:itemPathPart])
            {
                equalityCounter++;
            }
        }
    }
    
    //accept only items with equal path components
    if (equalityCounter == directoryParts.count)
    {
        return YES;
    }
    
    return NO;
}

@end
