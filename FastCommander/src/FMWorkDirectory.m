//
//  WorkDirectory.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMWorkDirectory.h"
#import "FMSettings.h"

@implementation FMWorkDirectory

@synthesize directory;
@synthesize error;

- (id)initWithDirectory:(NSString *)value
{
    self = [super init];
    
    if (self)
    {
        [self setDirectory: [[NSURL alloc] initFileURLWithPath: value isDirectory: YES]];
    }
    
    return self;
}

- (void)setWorkDirectory:(NSString *)value
{
    self.directory = [[NSURL alloc] initFileURLWithPath: value isDirectory: YES];
}

- (NSDirectoryEnumerationOptions)getOptions
{
    NSDirectoryEnumerationOptions options = 0;
    
    if (FMSettings.instance.isHiddenFilesVisible == YES)
    {
        options = 0;
    }
    else
    {
        options = options | NSDirectoryEnumerationSkipsHiddenFiles;
    }

    return options;
}

- (NSArray *)loadUrlItems
{
    NSError *_error = nil;
    
    NSArray *properties = [NSArray arrayWithObjects:
        NSURLNameKey,
        NSURLFileSizeKey,
        NSURLCreationDateKey,
        NSURLContentModificationDateKey,
        NSURLLocalizedTypeDescriptionKey,
        NSURLIsDirectoryKey,
        NSURLIsReadableKey,
        NSURLIsWritableKey,
        NSURLIsExecutableKey,
        NSURLIsHiddenKey,
        NSURLIsSymbolicLinkKey,
        NSURLIsVolumeKey,
        nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //get NSURL objects array
    NSArray *nsurlItems = [fileManager
        contentsOfDirectoryAtURL: directory
        includingPropertiesForKeys: properties
        options: [self getOptions]
        error: &_error];
    
    [self setError: _error];
    
    return nsurlItems;
}

- (NSString *)getUpDirectoryName
{
    NSURL *path = [directory copy];
    
    if ([FMWorkDirectory isRootDirectory:path.path])
    {
        return nil;
    }
    
    return [path lastPathComponent];
}

- (NSURL *)getUpDirectory
{
    NSURL *path = [directory copy];
    
    if ([FMWorkDirectory isRootDirectory:path.path])
    {
        return path;
    }
    
    return [path URLByDeletingLastPathComponent];
}

- (NSURL *)getDownDirectory:(NSString *)value
{
    NSURL *path = [directory copy];
    
    return [path URLByAppendingPathComponent:value isDirectory:YES];
}

+ (BOOL)isLocalDirectory:(NSString *)path
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    
    NSError *_error = nil;
    
    NSNumber *_isDirectory = nil;
    NSNumber *_isReadable = nil;
    
    if ([url getResourceValue: &_isDirectory forKey: NSURLIsDirectoryKey error: &_error])
    {
        if ([url getResourceValue: &_isReadable forKey: NSURLIsReadableKey error: &_error])
        {
            if (_isDirectory != nil && (_isDirectory.integerValue == 1))
            {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)isPathAccessible:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
    
    NSError *err;
    
    return ([url checkResourceIsReachableAndReturnError:&err] == YES);
}

+ (BOOL)isRootDirectory:(NSString *)path
{
    if (path.isAbsolutePath)
    {
        if ([path.stringByStandardizingPath isEqualToString:@"/"])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSArray *)getMountedVolumes
{
    return [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes];
}

+ (NSURL *)getUserDirectory
{
    return [NSURL fileURLWithPath:NSHomeDirectory()];
}

+ (NSURL *)getUsersDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSAllDomainsMask];

    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }

    return nil;
}

+ (NSURL *)getDocumentsDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getDownloadsDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getPublicDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSSharedPublicDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getDesktopDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getMoviesDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSMoviesDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getMusicDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSMusicDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSURL *)getPicturesDirectory
{
    NSArray *items = [[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSAllDomainsMask];
    
    if (items && items.count > 0)
    {
        return [items objectAtIndex:0];
    }
    
    return nil;
}

+ (NSString *)getPreviousName:(NSString *)previousPath currPath:(NSString *)currentPath
{
    if (previousPath == nil || currentPath == nil)
    {
        return nil;
    }
    
    //check if both paths begin is the same
    if ([previousPath hasPrefix:currentPath])
    {
        NSRange range = [previousPath rangeOfString:currentPath];
        
        NSString *name = [previousPath stringByReplacingCharactersInRange:range withString:@""];
        
        return [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    else
    {
        return nil;
    }
}

@end
