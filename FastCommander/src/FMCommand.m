//
//  FMCommand.m
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMCommand.h"
#import "AppDelegate.h"
#import "FMCommandManager.h"
#import "FMFileOperationValidator.h"

@implementation FMCommand

- (id)initWith:(FMCommandId)commandId withName:(NSString *)commandName path:(NSString *)path
{
    self = [super init];
    
    if (self)
    {
        self.commandId = commandId;
        self.commandName = commandName;
        self.path = [path copy];
        self.sourceObject = nil;
        self.panelSide = 0;
        self.panelMode = 0;
        self.selectionMode = 0;
        self.selectionPattern = nil;
        self.text = nil;
        self.message = nil;

        self.isSinglePanel = NO;
        self.isSelectionRequired = NO;
    }
    
    return self;
}

- (id)initWith:(FMCommandId)commandId withName:(NSString *)commandName listItem:(FMPanelListItem *)listItem
{
    self = [super init];
    
    if (self)
    {
        self.commandId = commandId;
        self.commandName = commandName;
        self.path = [listItem.unifiedFilePath copy];
        self.listItem = [listItem copy];
        self.sourceObject = nil;
        self.panelSide = 0;
        self.panelMode = 0;
        self.selectionMode = 0;
        self.selectionPattern = nil;
        self.text = nil;
        self.message = nil;

        self.isSinglePanel = NO;
        self.isSelectionRequired = NO;
    }
    
    return self;
}

- (id)initWith:(FMCommandId)commandId withName:(NSString *)commandName from:(FMPanelListProvider *)source to:(FMPanelListProvider *)target
{
    self = [super init];
    
    if (self)
    {
        self.commandId = commandId;
        self.commandName = commandName;
        self.path = nil;
        self.listItem = nil;
        self.sourceObject = nil;
        self.panelSide = 0;
        self.panelMode = 0;
        self.selectionMode = 0;
        self.selectionPattern = nil;
        self.text = nil;
        self.message = nil;
        self.operationSource = source;
        self.operationTarget = target;
        
        self.isSinglePanel = NO;
        self.isSelectionRequired = NO;
    }
    
    return self;
}

- (void)execute
{
    [FMCommandManager executeCommand:self];
}

+ (FMCommand *)directoryUp:(NSString *)value
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_directoryUp withName:@"DIRECTORY UP" path:value];
    
    return command;
}

+ (FMCommand *)directoryDown:(FMPanelListItem *)listItem
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_directoryDown withName:@"DIRECTORY DOWN" listItem:listItem];
    
    return command;    
}

+ (FMCommand *)processFile:(FMPanelListItem *)listItem
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_processFile withName:@"PROCESS FILE" listItem:listItem];
    
    return command;
}

+ (FMCommand *)selectItem:(NSString *)value
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_selectItem withName:@"SELECT ITEM" path:value];
    
    return command;
}

+ (FMCommand *)selectItems
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_selectItems withName:@"SELECT ITEMS" path:nil];
    
    return command;
}

+ (FMCommand *)updateSummary
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_updateSummary withName:@"UPDATE SUMMARY" path:nil];
    
    return command;
}

+ (FMCommand *)showDirectories
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_showDirectories withName:@"SHOW DIRECTORIES" path:nil];
    
    return command;    
}

+ (FMCommand *)setPanelMode:(FMPanelMode)mode
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_setPanelMode withName:@"SET PANEL MODE" path:nil];

    command.panelMode = mode;
    
    return command;
}

+ (FMCommand *)setSameDirectoryOnTarget
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_setSameDirectoryOnTarget withName:@"SET SAME DIRECTORY ON TARGET" path:nil];
    
    return command;
}

+ (FMCommand *)showSelectionPanel:(FMSelectionMode)mode withPattern:(NSString *)pattern
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_showSelectionPanel withName:@"SHOW SELECTION PANEL" path:nil];
        
    command.selectionMode = mode;
    command.selectionPattern = pattern;
    
    return command;
}

+ (FMCommand *)updateItemsSelection:(FMSelectionMode)mode withPattern:(NSString *)pattern
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_updateItemsSelection withName:@"UPDATE ITEMS SELECTION" path:nil];
    
    command.selectionMode = mode;
    command.selectionPattern = pattern;
    
    return command;    
}

+ (FMCommand *)updateBottomStatusText:(NSString *)value
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_updateBottomStatusText withName:@"UPDATE BOTTOM STATUS TEXT" path:nil];
    
    command.text = value;
    
    return command;
}

+ (FMCommand *)showAlert:(NSString *)message withTitle:(NSString *)title
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_showAlert withName:@"SHOW ALERT" path:nil];
    
    command.message = message;
    command.text = title;
    
    return command;
}

+ (FMCommand *)showPreferences
{
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_showPreferences withName:@"PREFERENCES" path:nil];
    
    return command;
}

+ (FMCommand *)fileOperationView
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_VIEW withName:@"VIEW" from:validator.sourceProvider to:nil];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationEdit
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];
    
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_EDIT withName:@"EDIT" from:validator.sourceProvider to:nil];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = YES;
    
    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationCopy
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_COPY withName:@"COPY" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = NO;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationMove
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_MOVE withName:@"MOVE" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = NO;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationDelete
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_DELETE withName:@"DELETE" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;    
}

+ (FMCommand *)fileOperationRename
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];
    
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_RENAME withName:@"RENAME" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationFolder
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_FOLDER withName:@"FOLDER" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = NO;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;
}

+ (FMCommand *)fileOperationCompress
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_COMPRESS withName:@"COMPRESS" from:validator.sourceProvider to:validator.targetProvider];
    
    command.isSinglePanel = NO;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;    
}

+ (FMCommand *)fileOperationPermissions
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];

    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_PERMISSIONS withName:@"PERMISSIONS" from:validator.sourceProvider to:nil];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = YES;

    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;    
}

+ (FMCommand *)fileOperationSearch
{
    FMFileOperationValidator *validator = [[FMFileOperationValidator alloc] init];
    
    FMCommand *command = [[FMCommand alloc] initWith:FMCommandId_fileOperation_SEARCH withName:@"SEARCH" from:validator.sourceProvider to:nil];
    
    command.isSinglePanel = YES;
    command.isSelectionRequired = NO;
    
    if ([validator validate:command])
    {
        return command;
    }
    
    return nil;    
}

@end
