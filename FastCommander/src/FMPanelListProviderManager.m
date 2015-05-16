//
//  FMPanelListProviderManager.m
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPanelListProviderManager.h"
#import "FMPanelListProvider.h"
#import "FMSearchPanelListProvider.h"
#import "FMLocalPanelListProvider.h"
#import "FMZipPanelListProvider.h"
#import "FMWorkDirectory.h"
#import "FMDirectoryViewController.h"
#import "AppDelegate.h"

@implementation FMPanelListProviderManager
{
    FMPanelListProvider *_currentProvider;

    FMPanelListProvider *_localProvider;
    FMPanelListProvider *_zipProvider;
    FMPanelListProvider *_searchProvider;
}

- (id)initForPanelSide:(FMPanelSide)panelSide;
{
    self = [super init];
    
    if (self)
    {
        self->_panelSide = panelSide;
        
        self->_localProvider = [[FMLocalPanelListProvider alloc] init];
        self->_zipProvider = [[FMZipPanelListProvider alloc] init];
        self->_searchProvider = [[FMSearchPanelListProvider alloc] init];

        //default to local provider
        self->_currentProvider = _localProvider;
    }
    
    return self;
}

- (FMPanelListProvider *)currentProvider
{
    return _currentProvider;
}

- (FMProviderType)currentProviderType
{
    if (_currentProvider == _localProvider)
    {
        return FMProviderTypeLocal;
    }

    if (_currentProvider == _zipProvider)
    {
        return FMProviderTypeZip;
    }

    if (_currentProvider == _searchProvider)
    {
        return FMProviderTypeSearch;
    }

    return FMProviderTypeUnknown;
}

- (FMSearchPanelListProvider *)searchProvider
{
    return (FMSearchPanelListProvider *)_searchProvider;
}

- (BOOL)isLocalDirectory:(NSString *)path
{
    NSString *resource = [_currentProvider getPathToResource:path];
    
    if (resource != nil)
    {
        if ([FMWorkDirectory isLocalDirectory:path])
        {
            return FMProviderTypeLocal;
        }
    }
    
    return NO;
}

- (FMProviderType)decodeProviderType:(NSString *)path
{
    if ([self isLocalDirectory:path])
    {
        return FMProviderTypeLocal;
    }
    
    if ([_zipProvider isPathValid:path])
    {
        return FMProviderTypeZip;
    }

    if ([_localProvider isPathValid:path])
    {
        return FMProviderTypeLocal;
    }

    if ([_searchProvider isPathValid:path])
    {
        return FMProviderTypeSearch;
    }

    return FMProviderTypeUnknown;
}

- (void)setProvider:(FMPanelListProvider *)provider
{
    self->_currentProvider = provider;

    FMDirectoryViewController *viewController = [AppDelegate.this viewController:self->_panelSide];
    
    [viewController setPanelListProvider:provider];
}

- (BOOL)setProviderByType:(FMProviderType)providerType withInitBasePath:(NSString *)path
{
    if (providerType == FMProviderTypeLocal)
    {
        if (_currentProvider != _localProvider)
        {
            [_currentProvider reset];
            
            [_localProvider initBasePath:path];
            
            _localProvider.nameToSelect = [_currentProvider getInitNameToSelect];
            
            [self setProvider:_localProvider];
        }
        
        //handled
        return YES;
    }
    
    if (providerType == FMProviderTypeZip)
    {
        if (_currentProvider != _zipProvider)
        {
            [_currentProvider reset];
            
            [_zipProvider initBasePath:path];
            
            _zipProvider.nameToSelect = [_currentProvider getInitNameToSelect];
            
            [self setProvider:_zipProvider];
        }
        
        //handled
        return YES;
    }
    
    if (providerType == FMProviderTypeSearch)
    {
        if (_currentProvider != _searchProvider)
        {
            [_currentProvider reset];
            
            if (_currentProvider == _localProvider)
            {
                path = _currentProvider.currentPath;
            }

            if (_currentProvider == _zipProvider)
            {
                path = _currentProvider.basePath;
            }

            [_searchProvider initBasePath:path];
            
            _searchProvider.nameToSelect = [_currentProvider getInitNameToSelect];
            
            [self setProvider:_searchProvider];
        }
        
        //handled
        return YES;
    }
    
    //not handled, process further
    return NO;    
}

- (BOOL)setProviderForPath:(NSString *)path
{
    FMProviderType providerType = [self decodeProviderType:path];

    return [self setProviderByType:providerType withInitBasePath:path];
}

@end
