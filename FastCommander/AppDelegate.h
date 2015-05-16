//
//  AppDelegate.h
//  FastCommander
//
//  Created by Piotr Zagawa on 13.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMMainViewController.h"
#import "FMRightDirectoryViewController.h"
#import "FMLeftDirectoryViewController.h"
#import "FMPanelListProviderManager.h"
#import "FMFileProcessingResolver.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly) FMFileProcessingResolver *fileProcessingResolver;

@property (weak) IBOutlet FMMainViewController *mainViewController;

@property (weak) IBOutlet FMRightDirectoryViewController *rightViewController;
@property (weak) IBOutlet FMLeftDirectoryViewController *leftViewController;

@property (readonly) FMPanelListProviderManager *rightListProviderManager;
@property (readonly) FMPanelListProviderManager *leftListProviderManager;

@property (readonly) FMPanelSide sourcePanelSide;
@property (readonly) FMPanelSide targetPanelSide;

@property (readonly) FMPanelListProvider *sourcePanelListProvider;
@property (readonly) FMPanelListProvider *targetPanelListProvider;

@property (readonly) FMDirectoryViewController *sourceViewController;
@property (readonly) FMDirectoryViewController *targetViewController;

+ (AppDelegate *)this;

- (FMPanelListProvider *)panelListProvider:(FMPanelSide)panelSide;
- (FMPanelListProviderManager *)panelListProviderManager:(FMPanelSide)panelSide;

- (FMDirectoryViewController *)viewController:(FMPanelSide)panelSide;
- (FMDirectoryViewController *)viewControllerForProvider:(FMPanelListProvider *)provider;

- (void)setPanelMode:(FMPanelMode)mode forPanelSide:(FMPanelSide)side;

- (void)setSameDirectoryOnTarget;

- (void)reloadSourcePanel:(OnReloadBlock)onReloadFinish;
- (void)reloadTargetPanel:(OnReloadBlock)onReloadFinish;
- (void)reloadBothPanels;

- (void)setSearchProviderWithData:(NSMutableArray *)fileItems andTitle:(NSString *)providerTitle;

@end
