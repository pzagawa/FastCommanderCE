//
//  FMDirectoryViewControllerContent.h
//  FastCommander
//
//  Created by Piotr Zagawa on 07.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMPanelListProvider.h"
#import "FMFilesTableView.h"

@interface FMDirectoryViewControllerContent : NSObject

@property (weak) FMPanelListProvider *listProvider;
@property (weak) FMFilesTableView *tableView;

- (id)init;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (FMSortedListItemsBy)sortModeFromSortDescriptor:(NSSortDescriptor *)descriptor;

- (void)sortPanelListItemsByColumn:(FMSortedListItemsBy)sortBy directionASC:(BOOL)dirASC;

@end
