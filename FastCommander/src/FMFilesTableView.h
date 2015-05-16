//
//  FMFilesTableView.h
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMCustomTypes.h"

@class FMReloadData;
@class FMPanelListItem;
@class FMPanelListProvider;

@interface FMFilesTableView : NSTableView

typedef void(^FMSelectionBlock)(int row, FMPanelListItem *listItem);

@property FMPanelSide panelSide;
@property FMPanelMode panelMode;

@property (weak) FMPanelListProvider *listProvider;

- (FMPanelListItem *)getSelectedPanelListItem;

- (void)highlightTableRow:(NSInteger)row;
- (void)selectFirstItem;
- (void)selectListItemByName:(NSString *)value;

- (void)saveListHighlightState;
- (void)restoreListHighlightState:(FMReloadData *)data;

- (void)toggleItemSelection;
- (void)processAllItemsSelection:(FMSelectionBlock)selectionBlock;
- (void)updateListItemByFileName:(NSString *)fileName withDirectorySize:(long long)size;

- (BOOL)validateMenuItem:(NSMenuItem *)item;

- (void)focusView;

- (NSString *)getDefaultGlobPattern;

- (void)updateBottomStatusTextWithCurrentlySelectedListItem;

- (void)initializeSorting;

@end
