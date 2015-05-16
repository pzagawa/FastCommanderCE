//
//  FMDirectoryViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 08.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMFilesTableView.h"
#import "FMFilesTableView+Commands.h"
#import "FMPanelListProvider.h"
#import "FMReloadData.h"
#import "FMPanelModeIndicator.h"
#import "FMLightProgressBar.h"
#import "FMAdvancedCombo.h"
#import "FMAdvancedComboEvents.h"
#import "FMScrollIndicator.h"
#import "FMPanelSortIndicator.h"

@interface FMDirectoryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, FMAdvancedComboEvents>

@property FMPanelSide panelSide;
@property FMPanelMode panelMode;

@property (weak) FMFilesTableView *tableView;

@property (weak) NSProgressIndicator *operationProgress;
@property (weak) NSButton *btnDirUp;
@property (weak) NSTextField *textSummary;
@property (weak) FMPanelModeIndicator *modeIndicator;
@property (weak) FMPanelSortIndicator *sortIndicator;
@property (weak) NSTextField *textVolumeName;
@property (weak) NSButton *btnSelection;
@property (weak) FMLightProgressBar *volumeInfoBar;
@property (weak) FMAdvancedCombo *editDirectory;
@property (weak) NSButton *btnOpenList;

@property (weak) FMScrollIndicator *scrollIndicator;
@property (weak) NSClipView *tableClipView;

@property (weak) NSPopover *selectionPopover;
@property (weak) NSView *viewBottomBar;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)initBeforeShow;
- (void)setPanelListProvider:(FMPanelListProvider *)listProvider;

- (void)reloadPanelWithPath:(NSString *)path parentOperation:(NSOperation *)parentOperation andBlockAfterOperation:(OnReloadBlock)onOperationFinish;
- (void)reloadPanelWithHomeDirectoryAndParentOperation:(NSOperation *)parentOperation;
- (void)reloadPanelWithDirectoryOfController:(FMDirectoryViewController *)controller andParentOperation:(NSOperation *)parentOperation;

- (void)onAfterPanelReload;
- (void)updateVolumeInfo;

- (FMPanelListItem *)getHighlightedListItem;

- (void)commandDirectorySet:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)side;
- (void)commandDirectoryUp;
- (void)commandProcessFile:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)side;
- (void)commandSelectItem:(NSString *)value;
- (void)commandSelectItems;
- (void)commandUpdateSummary;
- (void)commandShowDirectories;
- (void)commandShowSelectionPanel:(FMSelectionMode)mode withPattern:(NSString *)pattern;
- (void)commandUpdateItemsSelection:(FMSelectionMode)mode withPattern:(NSString *)pattern;

- (void)setPanelMode:(FMPanelMode)mode;

- (void)actionOpenDirectoryList:(id)sender;

- (void)clearAllItemsSelection;

- (void)resetSortMode;

@end
