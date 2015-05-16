//
//  FileManager.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileManager.h"

@implementation FMFileManager

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.isLoadingData = NO;
    }
    
    return self;
}

- (void)reset
{
    self.isLoadingData = YES;
    
    @try
    {
        self.urlItems = [[NSMutableArray alloc] init];
    }
    @finally
    {
        self.isLoadingData = NO;
    }
}

- (void)reload
{
    self.isLoadingData = YES;
    
    @try
    {
        self.urlItems = [self.directory loadUrlItems];
    }
    @finally
    {
        self.isLoadingData = NO;
    }
}

- (void)reload:(NSString *)value
{
    self.isLoadingData = YES;
    
    @try
    {
        [self setDirectory: [[FMWorkDirectory alloc] initWithDirectory:value]];
                
        [self.directory setWorkDirectory:value];
        
        self.urlItems = [self.directory loadUrlItems];
    }
    @finally
    {
        self.isLoadingData = NO;
    }
}

- (NSString *)getVolumeNameForPath:(NSString *)value
{
    NSURL *url = [NSURL fileURLWithPath:value];
    
    NSError *error;
    NSString *volumeName;
    
    if ([url getResourceValue:&volumeName forKey:NSURLVolumeLocalizedNameKey error:&error])
    {
        return volumeName;
    }
    
    return nil;
}

- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)value
{
    NSURL *url = [NSURL fileURLWithPath:value];
    
    NSError *error;
    NSNumber *size;
    
    if ([url getResourceValue:&size forKey:NSURLVolumeTotalCapacityKey error:&error])
    {
        return size;
    }
    
    return nil;
}

- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)value
{
    NSURL *url = [NSURL fileURLWithPath:value];
    
    NSError *error;
    NSNumber *size;
    
    if ([url getResourceValue:&size forKey:NSURLVolumeAvailableCapacityKey error:&error])
    {
        return size;
    }
    
    return nil;
}

@end
