//
//  FMPanelListProviderManager.h
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"
#import "FMPanelListProvider.h"

@class FMSearchPanelListProvider;

@interface FMPanelListProviderManager : NSObject

@property (readonly) FMPanelSide panelSide;

@property (readonly) FMPanelListProvider *currentProvider;
@property (readonly) FMProviderType currentProviderType;

@property (readonly) FMSearchPanelListProvider *searchProvider;

- (id)initForPanelSide:(FMPanelSide)panelSide;

- (BOOL)setProviderByType:(FMProviderType)providerType withInitBasePath:(NSString *)path;
- (BOOL)setProviderForPath:(NSString *)path;

@end
