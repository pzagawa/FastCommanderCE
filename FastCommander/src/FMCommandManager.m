//
//  FMCommandManager.m
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMCommandManager.h"
#import "AppDelegate.h"
#import "FMFileViewOperation.h"
#import "FMFileEditOperation.h"
#import "FMFileCopyOperation.h"
#import "FMFileDeleteOperation.h"
#import "FMFileRenameOperation.h"
#import "FMFileFolderOperation.h"
#import "FMFilePermissionsOperation.h"
#import "FMFileCompressOperation.h"
#import "FMFileSearchOperation.h"

@implementation FMCommandManager

+ (void)executeCommand:(FMCommand *)command
{
    //COMMAND directoryDown
    if (command.commandId == FMCommandId_directoryDown)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandDirectorySet:command.listItem forPanelSide:command.panelSide];
    }

    //COMMAND directoryUp
    if (command.commandId == FMCommandId_directoryUp)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandDirectoryUp];
    }

    //COMMAND processFile
    if (command.commandId == FMCommandId_processFile)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandProcessFile:command.listItem forPanelSide:command.panelSide];
    }

    //COMMAND selectItem
    if (command.commandId == FMCommandId_selectItem)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandSelectItem:command.path];
    }

    //COMMAND selectItems
    if (command.commandId == FMCommandId_selectItems)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandSelectItems];
    }

    //COMMAND updateSummary
    if (command.commandId == FMCommandId_updateSummary)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandUpdateSummary];
    }

    //COMMAND showDirectories
    if (command.commandId == FMCommandId_showDirectories)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandShowDirectories];
    }

    //COMMAND setPanelMode
    if (command.commandId == FMCommandId_setPanelMode)
    {
        [AppDelegate.this setPanelMode:command.panelMode forPanelSide:command.panelSide];
    }

    //COMMAND setSameDirectoryOnTarget
    if (command.commandId == FMCommandId_setSameDirectoryOnTarget)
    {
        [AppDelegate.this setSameDirectoryOnTarget];
    }

    //COMMAND showSelectionPanel
    if (command.commandId == FMCommandId_showSelectionPanel)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandShowSelectionPanel:command.selectionMode withPattern:command.selectionPattern];
    }
    
    //COMMAND updateItemsSelection
    if (command.commandId == FMCommandId_updateItemsSelection)
    {
        FMDirectoryViewController *viewController = [[AppDelegate this] viewController:command.panelSide];
        
        [viewController commandUpdateItemsSelection:command.selectionMode withPattern:command.selectionPattern];
    }

    //COMMAND updateBottomStatusText
    if (command.commandId == FMCommandId_updateBottomStatusText)
    {
        FMMainViewController *viewController = [[AppDelegate this] mainViewController];
     
        [viewController updateBottomStatus:command.text];
    }
    
    //COMMAND showAlert
    if (command.commandId == FMCommandId_showAlert)
    {
        FMMainViewController *viewController = [[AppDelegate this] mainViewController];
        
        [viewController showAlert:command.message title:command.text];
    }

    //COMMAND showPreferences
    if (command.commandId == FMCommandId_showPreferences)
    {
        FMMainViewController *viewController = [[AppDelegate this] mainViewController];
        
        [viewController showPreferences];
    }

    //COMMAND operationViewFiles
    if (command.commandId == FMCommandId_fileOperation_VIEW)
    {
        [FMFileViewOperation executeOn:command.operationSource];
    }

    //COMMAND operationEditFiles
    if (command.commandId == FMCommandId_fileOperation_EDIT)
    {
        [FMFileEditOperation executeOn:command.operationSource];
    }

    //COMMAND operationCopyFiles
    if (command.commandId == FMCommandId_fileOperation_COPY)
    {
        [FMFileCopyOperation executeFrom:command.operationSource to:command.operationTarget withMode:FMFileCopyOperationMode_COPY];
    }

    //COMMAND operationMoveFiles
    if (command.commandId == FMCommandId_fileOperation_MOVE)
    {
        [FMFileCopyOperation executeFrom:command.operationSource to:command.operationTarget withMode:FMFileCopyOperationMode_MOVE];
    }

    //COMMAND operationDeleteFiles
    if (command.commandId == FMCommandId_fileOperation_DELETE)
    {
        [FMFileDeleteOperation executeFrom:command.operationSource to:command.operationTarget];
    }

    //COMMAND operationRenameFiles
    if (command.commandId == FMCommandId_fileOperation_RENAME)
    {
        [FMFileRenameOperation executeFrom:command.operationSource to:command.operationTarget];
    }

    //COMMAND operationCreateFolder
    if (command.commandId == FMCommandId_fileOperation_FOLDER)
    {
        [FMFileFolderOperation executeFrom:command.operationSource to:command.operationTarget];
    }

    //COMMAND operationCompress
    if (command.commandId == FMCommandId_fileOperation_COMPRESS)
    {
        [FMFileCompressOperation executeFrom:command.operationSource to:command.operationTarget];
    }

    //COMMAND operationPermissions
    if (command.commandId == FMCommandId_fileOperation_PERMISSIONS)
    {
        [FMFilePermissionsOperation executeOn:command.operationSource];
    }

    //COMMAND operationSearch
    if (command.commandId == FMCommandId_fileOperation_SEARCH)
    {
        [FMFileSearchOperation executeOn:command.operationSource];
    }

}

@end
