//
//  FMTheme.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMTheme.h"
#import "FMPanelListItem.h"

@implementation FMTheme

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (NSString *)description
{
    return self.themeName;
}

- (NSColor *)cellDefaultTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    NSColor* color = self.rowDefaultText;
    
    if (isDirectory)
    {
        color = self.rowDirectoryText;
    }
    
    if (isHidden)
    {
        color = self.rowHiddenText;
    }
    
    if (isArchive)
    {
        color = self.rowArchiveText;
    }
    
    return color;
}

- (NSColor *)cellSelectedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    NSColor* color = self.rowDefaultSelectedText;
    
    if (isDirectory)
    {
        color = self.rowDirectorySelectedText;
    }
    
    if (isHidden)
    {
        color = self.rowHiddenSelectedText;
    }

    if (isArchive)
    {
        color = self.rowArchiveSelectedText;
    }
    
    return color;
}

- (NSColor *)cellHighlightedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    NSColor* color = self.rowDefaultHighlightText;
    
    if (isDirectory)
    {
        color = self.rowDirectoryHighlightText;
    }
    
    if (isHidden)
    {
        color = self.rowHiddenHighlightText;
    }
    
    if (isArchive)
    {
        color = self.rowArchiveHighlightText;
    }

    return color;
}

- (FMThemeColorKey)keyForCellDefaultTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    FMThemeColorKey key = FMThemeColorKey_rowDefaultText;
    
    if (isDirectory)
    {
        key = FMThemeColorKey_rowDirectoryText;
    }
    
    if (isHidden)
    {
        key = FMThemeColorKey_rowHiddenText;
    }
    
    if (isArchive)
    {
        key = FMThemeColorKey_rowArchiveText;
    }
    
    return key;
}

- (FMThemeColorKey)keyForCellSelectedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    FMThemeColorKey key = FMThemeColorKey_rowDefaultSelectedText;
    
    if (isDirectory)
    {
        key = FMThemeColorKey_rowDirectorySelectedText;
    }
    
    if (isHidden)
    {
        key = FMThemeColorKey_rowHiddenSelectedText;
    }
    
    if (isArchive)
    {
        key = FMThemeColorKey_rowArchiveSelectedText;
    }
    
    return key;
}

- (FMThemeColorKey)keyForCellHighlightedTextColor:(BOOL)isDirectory isHidden:(BOOL)isHidden isArchive:(BOOL)isArchive
{
    FMThemeColorKey key = FMThemeColorKey_rowDefaultHighlightText;
    
    if (isDirectory)
    {
        key = FMThemeColorKey_rowDirectoryHighlightText;
    }
    
    if (isHidden)
    {
        key = FMThemeColorKey_rowHiddenHighlightText;
    }
    
    if (isArchive)
    {
        key = FMThemeColorKey_rowArchiveHighlightText;
    }
    
    return key;
}

@end
