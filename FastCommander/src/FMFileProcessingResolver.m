//
//  FMFileProcessingResolver.m
//  FastCommander
//
//  Created by Piotr Zagawa on 28.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileProcessingResolver.h"
#import "AppDelegate.h"

@implementation FMFileProcessingResolver

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (BOOL)onFileItemSelected:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)panelSide
{
    NSString *path = listItem.unifiedFilePath;

    FMPanelListProviderManager *panelListProviderManager = [AppDelegate.this panelListProviderManager:panelSide];
    
    if ([panelListProviderManager setProviderForPath:[path copy]])
    {
        return YES;
    }
    else
    {
        [self openFileWithFinder:listItem];

        return NO;
    }
}

- (void)openFileWithFinder:(FMPanelListItem *)listItem
{
    NSString *path = listItem.unifiedFilePath;
    
    if (listItem.isSymbolicLink)
    {
        NSString *resultPath = listItem.symbolicLinkPath;
        
        if (resultPath != nil)
        {
            path = resultPath;
        }
    }
    
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (BOOL)onPathSet:(NSString *)value forPanelSide:(FMPanelSide)panelSide
{
    NSString *path = [value copy];

    FMPanelListProviderManager *panelListProviderManager = [AppDelegate.this panelListProviderManager:panelSide];
    
    if ([panelListProviderManager setProviderForPath:path])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
