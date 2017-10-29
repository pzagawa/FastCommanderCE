//
//  FMCustomTypes.h
//  FastCommander
//
//  Created by Piotr Zagawa on 08.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCustomTypes : NSObject

//USED by FMPosix Permissions
typedef NS_ENUM(NSUInteger, FM_POSIX_BITS)
{
    POSIX_BITS_ALL_SET = 0b111111111,

    POSIX_BITS_USER = 0b111000000,
    POSIX_BITS_GRUP = 0b000111000,
    POSIX_BITS_OTHR = 0b000000111,
    
    POSIX_BIT_USER_R = 0b100000000,
    POSIX_BIT_USER_W = 0b010000000,
    POSIX_BIT_USER_X = 0b001000000,
    
    POSIX_BIT_GRUP_R = 0b000100000,
    POSIX_BIT_GRUP_W = 0b000010000,
    POSIX_BIT_GRUP_X = 0b000001000,
    
    POSIX_BIT_OTHR_R = 0b000000100,
    POSIX_BIT_OTHR_W = 0b000000010,
    POSIX_BIT_OTHR_X = 0b000000001,
};

//USED by FMCommand
typedef enum
{
    FMPanelSideUnspecified = 0,
    FMPanelSideL = 1,
    FMPanelSideR = 2,
    
} FMPanelSide;

//USED by panel mode icon
typedef enum
{
    FMPanelModeSource = 1,
    FMPanelModeTarget = 2,
    
} FMPanelMode;

//USED by FMPanelListItem
typedef enum
{
    //default list item type
    FMPanelListItemTypeDefault = 0,
    
    //action list item type: DirectoryUp (..)
    FMPanelListItemTypeDirUp = 1,
    
} FMPanelListItemType;

//USED by FMFilesTableViewHelper events
typedef enum
{
    FMKeyCode_ESCAPE = 0x35,
    FMKeyCode_ENTER = 0x24,
    FMKeyCode_TAB = 0x30,
    FMKeyCode_SPACE = 0x31,
    FMKeyCode_BACKSPACE = 0x33,
    FMKeyCode_F1 = 0x7A,
    FMKeyCode_F2 = 0x78,
    FMKeyCode_PageDown = 0x79,
    FMKeyCode_PageUp = 0x74,
    FMKeyCode_DELETE = 0x75,
    FMKeyCode_Home = 0x73,
    FMKeyCode_End = 0x77,
    FMKeyCode_Plus = 0x45,
    FMKeyCode_Minus = 0x4E,
    FMKeyCode_Asterisk = 0x43,
    FMKeyCode_1 = 0x12,
    FMKeyCode_2 = 0x13,
    FMKeyCode_Left = 123,
    FMKeyCode_Right = 124
    
} FMKeyCode;

//USED by FMSelectionViewController
typedef enum
{
    FMSelectionMode_SELECT = 1,
    FMSelectionMode_UNSELECT = 2,
    
} FMSelectionMode;

//Commands id's, USED by FMCommand
typedef enum
{
    FMCommandId_directoryUp,
    FMCommandId_directoryDown,
    FMCommandId_processFile,
    FMCommandId_selectItem,
    FMCommandId_selectItems,
    FMCommandId_updateSummary,
    FMCommandId_showDirectories,
    FMCommandId_setPanelMode,
    FMCommandId_setSameDirectoryOnTarget,
    FMCommandId_showSelectionPanel,
    FMCommandId_updateItemsSelection,
    FMCommandId_updateBottomStatusText,
    
    FMCommandId_showAlert,
    FMCommandId_showPreferences,
    
    FMCommandId_fileOperation_VIEW,
    FMCommandId_fileOperation_EDIT,
    FMCommandId_fileOperation_COPY,
    FMCommandId_fileOperation_MOVE,
    FMCommandId_fileOperation_DELETE,
    FMCommandId_fileOperation_RENAME,
    FMCommandId_fileOperation_FOLDER,

    FMCommandId_fileOperation_COMPRESS,
    FMCommandId_fileOperation_PERMISSIONS,

    FMCommandId_fileOperation_SEARCH,
    
} FMCommandId;

//USED by FMFileItem
typedef enum
{
    FMFileItemStatus_SOURCE_MOVE_ERROR = -13,
    FMFileItemStatus_NOT_ENOUGH_SPACE_ON_TARGET = -12,
    FMFileItemStatus_TARGET_NOT_SUPPORTS_BIG_FILES = -11,
    FMFileItemStatus_SOURCE_REMOVE_ERROR = -10,
    FMFileItemStatus_TARGET_DIRECTORY_ERROR = -9,
    FMFileItemStatus_SOURCE_TARGET_EQUAL_ERROR = -8,
    FMFileItemStatus_TARGET_EXISTS_ERROR = -7,
    FMFileItemStatus_TARGET_FILENAME_ERROR = -6,
    FMFileItemStatus_READ_ERROR = -5,
    FMFileItemStatus_WRITE_ERROR = -4,
    FMFileItemStatus_INPUT_OPEN_ERROR = -3,
    FMFileItemStatus_OUTPUT_OPEN_ERROR = -2,
    FMFileItemStatus_ERROR = -1,
    FMFileItemStatus_TODO = 0,
    FMFileItemStatus_DONE = 1,
    FMFileItemStatus_CANCELED = 2,
    
} FMFileItemStatus;

@end
