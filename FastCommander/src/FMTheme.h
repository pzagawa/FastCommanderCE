//
//  FMTheme.h
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMTheme : NSObject

@property NSString *themeName;

@property NSColor *listBackground;
@property NSColor *listHighlightedRow;
@property NSColor *listSelectedRow;
@property NSColor *iconSelectedRow;
@property NSColor *iconSelectedRowInv;

//default row text color set
@property NSColor *rowDefaultText;
@property NSColor *rowDirectoryText;
@property NSColor *rowHiddenText;
@property NSColor *rowArchiveText;

//selected row text color set
@property NSColor *rowDefaultSelectedText;
@property NSColor *rowDirectorySelectedText;
@property NSColor *rowHiddenSelectedText;
@property NSColor *rowArchiveSelectedText;

//highlighted row text color set
@property NSColor *rowDefaultHighlightText;
@property NSColor *rowDirectoryHighlightText;
@property NSColor *rowHiddenHighlightText;
@property NSColor *rowArchiveHighlightText;
@property NSColor *rowHighlightTextShadow;

//Theme color key
typedef enum
{
    FMThemeColorKey_NULL,

    FMThemeColorKey_rowDefaultText,
    FMThemeColorKey_rowDirectoryText,
    FMThemeColorKey_rowHiddenText,
    FMThemeColorKey_rowArchiveText,
    
    FMThemeColorKey_rowDefaultSelectedText,
    FMThemeColorKey_rowDirectorySelectedText,
    FMThemeColorKey_rowHiddenSelectedText,
    FMThemeColorKey_rowArchiveSelectedText,
    
    FMThemeColorKey_rowDefaultHighlightText,
    FMThemeColorKey_rowDirectoryHighlightText,
    FMThemeColorKey_rowHiddenHighlightText,
    FMThemeColorKey_rowArchiveHighlightText,
    FMThemeColorKey_rowHighlightTextShadow,

} FMThemeColorKey;

- (id)init;
- (NSString *)description;

- (NSColor *)cellDefaultTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;
- (NSColor *)cellSelectedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;
- (NSColor *)cellHighlightedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;

- (FMThemeColorKey)keyForCellDefaultTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;
- (FMThemeColorKey)keyForCellSelectedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;
- (FMThemeColorKey)keyForCellHighlightedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive;

@end
