//
//  FMCommand.h
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"
#import "FMPanelListItem.h"
#import "FMPanelListProvider.h"

@interface FMCommand : NSObject

@property NSString *path;
@property FMPanelListItem *listItem;

@property FMCommandId commandId;
@property NSString *commandName;

@property BOOL isSinglePanel;
@property BOOL isSelectionRequired;

@property (weak) id sourceObject;
@property FMPanelSide panelSide;
@property FMPanelMode panelMode;
@property FMSelectionMode selectionMode;
@property (copy) NSString *selectionPattern;
@property (copy) NSString *text;
@property (copy) NSString *message;

@property (weak) FMPanelListProvider *operationSource;
@property (weak) FMPanelListProvider *operationTarget;

- (void)execute;

+ (FMCommand *)directoryUp:(NSString *)value;
+ (FMCommand *)directoryDown:(FMPanelListItem *)listItem;
+ (FMCommand *)processFile:(FMPanelListItem *)listItem;
+ (FMCommand *)selectItem:(NSString *)value;
+ (FMCommand *)selectItems;
+ (FMCommand *)updateSummary;
+ (FMCommand *)showDirectories;
+ (FMCommand *)setPanelMode:(FMPanelMode)mode;
+ (FMCommand *)setSameDirectoryOnTarget;
+ (FMCommand *)showSelectionPanel:(FMSelectionMode)mode withPattern:(NSString *)pattern;
+ (FMCommand *)updateItemsSelection:(FMSelectionMode)mode withPattern:(NSString *)pattern;
+ (FMCommand *)updateBottomStatusText:(NSString *)value;

+ (FMCommand *)showAlert:(NSString *)message withTitle:(NSString *)title;
+ (FMCommand *)showPreferences;

+ (FMCommand *)fileOperationView;
+ (FMCommand *)fileOperationEdit;
+ (FMCommand *)fileOperationCopy;
+ (FMCommand *)fileOperationMove;
+ (FMCommand *)fileOperationDelete;
+ (FMCommand *)fileOperationRename;
+ (FMCommand *)fileOperationFolder;

+ (FMCommand *)fileOperationCompress;
+ (FMCommand *)fileOperationPermissions;

+ (FMCommand *)fileOperationSearch;

@end
