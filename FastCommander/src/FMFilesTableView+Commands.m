//
//  FMFilesTableView+Commands.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFilesTableView+Commands.h"
#import "FMFilesTableView.h"
#import "FMCommandManager.h"
#import "AppDelegate.h"

@implementation FMFilesTableView (Commands)

- (BOOL)processSwitchPanelCommmand
{
    FMDirectoryViewController *vc;
    
    if (self.panelSide == FMPanelSideL)
    {
        vc = [AppDelegate.this viewController:FMPanelSideR];
    }
    
    if (self.panelSide == FMPanelSideR)
    {
        vc = [AppDelegate.this viewController:FMPanelSideL];
    }

    [AppDelegate.this.mainViewController.window makeFirstResponder:vc.tableView];
    
    return NO;
}

- (BOOL)processSelectionCommmand
{
    [self toggleItemSelection];
    
    FMPanelListItem *listItem = [self getSelectedPanelListItem];
    
    if (listItem != nil)
    {
        FMCommand *command = [FMCommand selectItem:[listItem.unifiedFilePath copy]];
        
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)processEnterCommmand
{
    FMCommand *command = nil;
    
    FMPanelListItem *listItem = [self getSelectedPanelListItem];
    
    if (listItem != nil)
    {
        //default item
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            if (listItem.isSymbolicLink)
            {
                NSString *path = listItem.symbolicLinkPath;
                
                if (path != nil)
                {
                    NSURL *url = [NSURL fileURLWithPath:path];
                    
                    listItem = [[FMPanelListItem alloc] initWithURL:url itemType:FMPanelListItemTypeDefault];
                }
            }
            
            if (listItem.isDirectory)
            {
                //directory
                command = [FMCommand directoryDown:listItem];
            }
            else
            {
                //file
                command = [FMCommand processFile:listItem];
            }
        }
        
        //action item
        if (listItem.itemType == FMPanelListItemTypeDirUp)
        {
            //directory up
            command = [FMCommand directoryUp:[listItem.unifiedFilePath copy]];
        }
    }
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)processDirectoryUpCommmand
{
    FMCommand *command = nil;
    
    FMPanelListItem *listItem = [self getSelectedPanelListItem];
    
    if (listItem != nil)
    {
        //directory up
        command = [FMCommand directoryUp:[listItem.unifiedFilePath copy]];
    }
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)processShowDirectoriesCommmandForPanel:(FMPanelSide)side;
{
    FMCommand *command = [FMCommand showDirectories];
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = side;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (void)processAllItemsSelectCommand
{
    [self processAllItemsSelection:^(int row, FMPanelListItem *listItem)
    {
        [listItem setSelected:YES];
    }];
}

- (void)processAllItemsUnselectCommand
{
    [self processAllItemsSelection:^(int row, FMPanelListItem *listItem)
    {
        [listItem setSelected:NO];
    }];
}

- (void)processAllItemsInvertCommand
{
    [self processAllItemsSelection:^(int row, FMPanelListItem *listItem)
    {
        [listItem setSelected:!listItem.isSelected];
    }];
}

- (void)processItemsSelectionCommand:(FMSelectionMode)mode withPattern:(NSString *)pattern
{
    [self processAllItemsSelection:^(int row, FMPanelListItem *listItem)
     {
         if ([listItem isItemsSelectionMatch:pattern])
         {
             [listItem setSelected:(mode == FMSelectionMode_SELECT)];
         }
     }];
}

- (BOOL)processShowSelectionPanelCommmand:(FMSelectionMode)mode withPattern:(NSString *)pattern
{
    FMCommand *command = [FMCommand showSelectionPanel:mode withPattern:pattern];
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)processSameDirectoryOnTarget
{
    FMCommand *command = [FMCommand setSameDirectoryOnTarget];
    
    if (command != nil)
    {
        command.sourceObject = self;

        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)processFileOperationDelete
{
    //processing by keyboard shortcut detected in runtime, not from menu
    FMPanelListItem *listItem = [self getSelectedPanelListItem];

    if (listItem != nil)
    {
        FMCommand *command = [FMCommand fileOperationDelete];
        
        if (command != nil)
        {
            command.sourceObject = self;
            
            [command execute];
            
            return YES;
        }
    }
    
    return NO;
}

//MENU actions
//------------------------------------------------

- (void)actionSelectItem:(id)sender
{
    [self processSelectionCommmand];
}

- (void)actionOpen:(id)sender
{
    [self processEnterCommmand];
}

- (void)actionDirectoryUp:(id)sender
{
    [self processDirectoryUpCommmand];
}

- (void)actionSelectLeftDirectory:(id)sender
{
    [self processShowDirectoriesCommmandForPanel:FMPanelSideL];
}

- (void)actionSelectRightDirectory:(id)sender
{
    [self processShowDirectoriesCommmandForPanel:FMPanelSideR];
}

- (void)actionSelectItemsByPattern:(id)sender
{
    [self processShowSelectionPanelCommmand:FMSelectionMode_SELECT withPattern:self.getDefaultGlobPattern];
}

- (void)actionUnselectItemsByPattern:(id)sender
{
    [self processShowSelectionPanelCommmand:FMSelectionMode_UNSELECT withPattern:self.getDefaultGlobPattern];
}

- (void)actionSelectAllItems:(id)sender
{
    [self processAllItemsSelectCommand];
}

- (void)actionUnselectAllItems:(id)sender
{
    [self processAllItemsUnselectCommand];
}

- (void)actionInvertAllItems:(id)sender
{
    [self processAllItemsInvertCommand];
}

- (void)actionSameDirectoryOnTarget:(id)sender
{
    [self processSameDirectoryOnTarget];    
}

- (BOOL)validateMenuItemInCategory:(NSMenuItem *)item
{
    SEL action = item.action;

    FMPanelListItem *listItem = [self getSelectedPanelListItem];
    
    if (listItem != nil)
    {
        //actionSelectItem
        if (action == @selector(actionSelectItem:))
        {
            if (listItem.itemType == FMPanelListItemTypeDefault)
            {
                return YES;
            }
        }
        
        //actionCommandOpen
        if (action == @selector(actionOpen:))
        {
            return YES;
        }
        
        //actionDirectoryUp
        if (action == @selector(actionDirectoryUp:))
        {
            return YES;
        }
        
        //actionSelectLeftDirectory
        if (action == @selector(actionSelectLeftDirectory:))
        {
            return YES;
        }
        
        //actionSelectRightDirectory
        if (action == @selector(actionSelectRightDirectory:))
        {
            return YES;
        }
        
        //actionSelectItemsByPattern
        if (action == @selector(actionSelectItemsByPattern:))
        {
            return YES;
        }
        
        //actionUnselectItemsByPattern
        if (action == @selector(actionUnselectItemsByPattern:))
        {
            return YES;
        }
        
        //actionSelectAllItems
        if (action == @selector(actionSelectAllItems:))
        {
            return YES;
        }
        
        //actionUnselectAllItems
        if (action == @selector(actionUnselectAllItems:))
        {
            return YES;
        }
        
        //actionInvertAllItems
        if (action == @selector(actionInvertAllItems:))
        {
            return YES;
        }
        
        //actionSameDirectoryOnTarget
        if (action == @selector(actionSameDirectoryOnTarget:))
        {
            return YES;
        }
    
    }
    
    return NO;
}

@end
