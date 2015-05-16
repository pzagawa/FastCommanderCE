//
//  FMFilesTableView+Commands.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMFilesTableView.h"

@interface FMFilesTableView (Commands)

- (BOOL)processSwitchPanelCommmand;
- (BOOL)processSelectionCommmand;
- (BOOL)processEnterCommmand;
- (BOOL)processDirectoryUpCommmand;
- (BOOL)processShowDirectoriesCommmandForPanel:(FMPanelSide)side;

- (void)processAllItemsSelectCommand;
- (void)processAllItemsUnselectCommand;
- (void)processAllItemsInvertCommand;
- (void)processItemsSelectionCommand:(FMSelectionMode)mode withPattern:(NSString *)pattern;
- (BOOL)processShowSelectionPanelCommmand:(FMSelectionMode)mode withPattern:(NSString *)pattern;
- (BOOL)processSameDirectoryOnTarget;
- (BOOL)processFileOperationDelete;

- (BOOL)validateMenuItemInCategory:(NSMenuItem *)item;

@end
