//
//  AppDelegate.m
//  FastCommander
//
//  Created by Piotr Zagawa on 13.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "AppDelegate.h"
#import "FMSettings.h"
#import "FMBookmarksManager.h"
#import "FMSearchPanelListProvider.h"
#import "FMFileItem.h"

@implementation AppDelegate
{
    BOOL _panelsReloadingEnabled;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_panelsReloadingEnabled = NO;
        
        self->_fileProcessingResolver = [[FMFileProcessingResolver alloc] init];

        self->_rightListProviderManager = [[FMPanelListProviderManager alloc] initForPanelSide:FMPanelSideR];
        self->_leftListProviderManager = [[FMPanelListProviderManager alloc] initForPanelSide:FMPanelSideL];
    }
    
    return self;
}

+ (AppDelegate *)this
{
    return (AppDelegate *)[NSApp delegate];
}

- (FMPanelListProvider *)panelListProvider:(FMPanelSide)panelSide
{
    if (panelSide == FMPanelSideR)
        return self.rightListProviderManager.currentProvider;
    
    if (panelSide == FMPanelSideL)
        return self.leftListProviderManager.currentProvider;
    
    return nil;
}

- (FMPanelListProviderManager *)panelListProviderManager:(FMPanelSide)panelSide
{
    if (panelSide == FMPanelSideR)
        return self.rightListProviderManager;
    
    if (panelSide == FMPanelSideL)
        return self.leftListProviderManager;
    
    return nil;
}

- (FMDirectoryViewController *)viewController:(FMPanelSide)panelSide
{
    if (panelSide == FMPanelSideR)
        return self->_rightViewController;

    if (panelSide == FMPanelSideL)
        return self->_leftViewController;
    
    return nil;
}

- (FMDirectoryViewController *)viewControllerForProvider:(FMPanelListProvider *)provider
{
    FMPanelSide panelSide = 0;
    
    if (self.rightListProviderManager.currentProvider == provider)
    {
        panelSide = FMPanelSideR;
    }

    if (self.self.leftListProviderManager.currentProvider == provider)
    {
        panelSide = FMPanelSideL;
    }

    return [self viewController:panelSide];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (self.mainViewController.activeFileOperation == nil)
    {
        return NSTerminateNow;
    }
    
    return NSTerminateCancel;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{    
    [self.mainViewController applicationWillTerminate:notification];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.mainViewController applicationShouldHandleReopen:theApplication hasVisibleWindows:flag];
    
    return YES;
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self refreshPanelsIfIdleAndContentChanged];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    self->_panelsReloadingEnabled = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    //init controllers
    [self.rightViewController initBeforeShow];
    [self.leftViewController initBeforeShow];
    
    //set app title
    [self.mainViewController updateTitle];
    
    //update bottom status
    [self.mainViewController updateBottomStatus:@""];
    [self.mainViewController updateBottomInfo];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.mainViewController applicationDidFinishLaunching:aNotification];
        
    //init view controllers
    [self.rightViewController setPanelListProvider:self->_rightListProviderManager.currentProvider];
    [self.leftViewController setPanelListProvider:self->_leftListProviderManager.currentProvider];
    
    //load home init directory
    [self reloadPanelsWithHomeDirectory];

    //initialize bookmarks
    FMBookmarksManager *bookmarksManager = [[FMBookmarksManager alloc] init];
    [bookmarksManager updateInBackground];
}

- (void)setPanelMode:(FMPanelMode)mode forPanelSide:(FMPanelSide)side
{
    if (side == FMPanelSideL)
    {
        if (mode == FMPanelModeSource)
        {
            [self.leftViewController setPanelMode:FMPanelModeSource];
            [self.rightViewController setPanelMode:FMPanelModeTarget];
        }
    }

    if (side == FMPanelSideR)
    {
        if (mode == FMPanelModeSource)
        {
            [self.leftViewController setPanelMode:FMPanelModeTarget];
            [self.rightViewController setPanelMode:FMPanelModeSource];
        }
    }
}

- (FMPanelSide)sourcePanelSide
{
    if (self.leftViewController.panelMode == FMPanelModeSource)
    {
        return FMPanelSideL;
    }
    
    if (self.rightViewController.panelMode == FMPanelModeSource)
    {
        return FMPanelSideR;
    }

    return 0;
}

- (FMPanelSide)targetPanelSide
{
    if (self.leftViewController.panelMode == FMPanelModeSource)
    {
        return FMPanelSideR;
    }
    
    if (self.rightViewController.panelMode == FMPanelModeSource)
    {
        return FMPanelSideL;
    }
    
    return 0;
}

- (FMPanelListProvider *)sourcePanelListProvider
{
    FMPanelSide panelSide = AppDelegate.this.sourcePanelSide;
    
    return [self panelListProvider:panelSide];
}

- (FMPanelListProvider *)targetPanelListProvider
{
    FMPanelSide panelSide = AppDelegate.this.targetPanelSide;
    
    return [self panelListProvider:panelSide];
}

- (FMDirectoryViewController *)sourceViewController
{
    FMPanelSide panelSide = AppDelegate.this.sourcePanelSide;
    
    return [self viewController:panelSide];
}

- (FMDirectoryViewController *)targetViewController
{
    FMPanelSide panelSide = AppDelegate.this.targetPanelSide;
    
    return [self viewController:panelSide];
}

- (void)setSameDirectoryOnTarget
{
    FMDirectoryViewController *source = self.sourceViewController;
    FMDirectoryViewController *target = self.targetViewController;
    
    FMPanelListProviderManager *sourceProviderManager = [self panelListProviderManager:source.panelSide];
    FMPanelListProviderManager *targetProviderManager = [self panelListProviderManager:target.panelSide];
    
    if (sourceProviderManager.currentProviderType != targetProviderManager.currentProviderType)
    {
        NSString *basePath = sourceProviderManager.currentProvider.basePath;
        
        [targetProviderManager setProviderByType:sourceProviderManager.currentProviderType withInitBasePath:basePath];
    }
    
    [target reloadPanelWithDirectoryOfController:source andParentOperation:nil];
}

- (void)setSearchProviderWithData:(NSMutableArray *)fileItems andTitle:(NSString *)providerTitle
{
    //set search provider data
    FMPanelListProviderManager *providerManager = [self panelListProviderManager:self.sourcePanelSide];
    
    providerManager.searchProvider.sourceFileItems = [fileItems copy];
    
    providerManager.searchProvider.providerTitle = [providerTitle copy];
    
    //switch current provider to search provider
    [providerManager setProviderByType:FMProviderTypeSearch withInitBasePath:@""];
    
    [self.sourceViewController reloadPanelWithPath:providerTitle parentOperation:nil andBlockAfterOperation:nil];
}

- (void)refreshPanelsIfIdleAndContentChanged
{
    if (self->_panelsReloadingEnabled)
    {
        if (self.mainViewController.activeFileOperation == nil)
        {
            if (self.mainViewController.activeOperationSheet == nil)
            {
                [self reloadPanelIfChanged:FMPanelSideL];
                [self reloadPanelIfChanged:FMPanelSideR];
            }
        }
    }
}

- (void)reloadPanelIfChanged:(FMPanelSide)panelSide
{
    FMPanelListProvider *provider = [self panelListProvider:panelSide];

    if (provider.currentPathContentChanged)
    {
        [provider resetPathContentChanged];
        
        FMDirectoryViewController *viewController = [self viewController:panelSide];
        
        [viewController reloadPanelWithPath:nil parentOperation:nil andBlockAfterOperation:^(FMReloadData *data){}];
    }
}

- (void)reloadPanelsWithHomeDirectory
{
    NSOperation *operation = [self commonReloadOperationForPanel:FMPanelSideR];

    [self.leftViewController reloadPanelWithHomeDirectoryAndParentOperation:operation];
    [self.rightViewController reloadPanelWithHomeDirectoryAndParentOperation:operation];

    [NSOperationQueue.mainQueue addOperation:operation];
}

- (void)reloadSourcePanel:(OnReloadBlock)onReloadFinish
{
    if (self.isReloadForOtherPanelRequired)
    {
        NSOperation *operation = [self commonReloadOperationForPanel:self.sourcePanelSide];
        
        [self.sourceViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:onReloadFinish];
        [self.targetViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:^(FMReloadData *data){}];
        
        [NSOperationQueue.mainQueue addOperation:operation];
    }
    else
    {
        [self.sourceViewController reloadPanelWithPath:nil parentOperation:nil andBlockAfterOperation:onReloadFinish];
    }
}

- (void)reloadTargetPanel:(OnReloadBlock)onReloadFinish
{
    if (self.isReloadForOtherPanelRequired)
    {
        NSOperation *operation = [self commonReloadOperationForPanel:self.targetPanelSide];
        
        [self.sourceViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:onReloadFinish];
        [self.targetViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:^(FMReloadData *data){}];
        
        [NSOperationQueue.mainQueue addOperation:operation];
    }
    else
    {
        NSOperation *operation = [self commonReloadOperationForPanel:self.sourcePanelSide];

        [self.targetViewController reloadPanelWithPath:nil parentOperation:nil andBlockAfterOperation:onReloadFinish];

        [NSOperationQueue.mainQueue addOperation:operation];
    }
}

- (void)reloadBothPanels
{
    NSOperation *operation = [self commonReloadOperationForPanel:self.sourcePanelSide];

    [self.sourceViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:^(FMReloadData *data){}];
    [self.targetViewController reloadPanelWithPath:nil parentOperation:operation andBlockAfterOperation:^(FMReloadData *data){}];

    [NSOperationQueue.mainQueue addOperation:operation];
}

- (BOOL)isReloadForOtherPanelRequired
{
    if ([self isBothPanelsTheSamePaths])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isBothPanelsTheSamePaths
{
    if (self.sourcePanelListProvider == nil)
    {
        return NO;
    }
    
    if (self.targetPanelListProvider == nil)
    {
        return NO;
    }
    
    return [self.sourcePanelListProvider.currentPath isEqualToString:self.targetPanelListProvider.currentPath];
}

- (BOOL)isBothPanelsTheSameVolumes
{
    if (self.sourcePanelListProvider == nil)
    {
        return NO;
    }
    
    if (self.targetPanelListProvider == nil)
    {
        return NO;
    }
    
    FMFileItem *sourceFileItem = [FMFileItem fromFilePath:self.sourcePanelListProvider.currentPath];
    FMFileItem *targetFileItem = [FMFileItem fromFilePath:self.targetPanelListProvider.currentPath];
    
    if ([sourceFileItem isTheSameVolume:targetFileItem])
    {
        return YES;
    }
    
    return NO;
}

- (NSOperation *)commonReloadOperationForPanel:(FMPanelSide)panelSide
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
    }];
    
    [operation setCompletionBlock:^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.leftViewController updateVolumeInfo];
            [self.rightViewController updateVolumeInfo];

            [self.leftViewController clearAllItemsSelection];
            [self.rightViewController clearAllItemsSelection];

            if (panelSide == FMPanelSideL)
            {
                [self.leftViewController onAfterPanelReload];
            }
            
            if (panelSide == FMPanelSideR)
            {
                [self.rightViewController onAfterPanelReload];
            }
        });
    }];
    
    return operation;
}

@end
