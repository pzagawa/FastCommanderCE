//
//  FMFilesTableViewDrawRow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 27.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFilesTableViewDrawRow.h"
#import "FMFilesTableView.h"
#import "NSPanelTextFieldCell.h"
#import "FMTheme.h"
#import "FMThemeManager.h"
#import "FMPanelListItem.h"
#import "FMResources.h"
#import "FMThemeManager.h"

@implementation FMFilesTableViewDrawRow
{
    FMTheme *_theme;
    NSFont *_cellFont;
    NSShadow *_textShadow;
    NSTextAlignment _columnAlignment[5];
    NSMutableDictionary *_cacheTextAttributes;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self updateTheme];
        
        //font
        self->_cellFont = [NSFont fontWithName: @"Menlo" size:12];
        
        if (self->_cellFont == nil)
        {
            self->_cellFont = [NSFont systemFontOfSize:12];
        }

        //column alignment
        self->_columnAlignment[0] = NSCenterTextAlignment;
        self->_columnAlignment[1] = NSLeftTextAlignment;
        self->_columnAlignment[2] = NSRightTextAlignment;
        self->_columnAlignment[3] = NSRightTextAlignment;
        self->_columnAlignment[4] = NSRightTextAlignment;
    }
    
    return self;
}

- (void)updateTheme
{
    self->_theme = FMThemeManager.instance.theme;
    
    //shadow
    self->_textShadow = [[NSShadow alloc] init];
    [self->_textShadow setShadowColor:_theme.rowHighlightTextShadow];
    [self->_textShadow setShadowBlurRadius:3.0];
    [self->_textShadow setShadowOffset:NSMakeSize(0, 0)];

    //cache for text attributes
    self->_cacheTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:50];
}

- (NSImage *)createSelectedImage:(NSTableView *)aTableView row:(NSInteger)row
{
    NSImage *image = nil;
    
    if (self.tableView.panelMode == FMPanelModeSource)
    {
        if (self.tableView.selectedRow == row)
        {
            //show inverted icon for selected row
            image = [[FMResources instance] imageItemSelectedInverted];
        }
        else
        {
            //show normal icon for all other rows
            image = [[FMResources instance] imageItemSelected];
        }
    }
    
    if (self.tableView.panelMode == FMPanelModeTarget)
    {
        //show normal icon for all other rows
        image = [[FMResources instance] imageItemSelected];
    }
    
    return image;
}

- (NSColor *)cellTextColorForListItem:(FMPanelListItem *)item row:(NSInteger)row
{
    BOOL isDirectory = item.isDirectory;
    BOOL isHidden = item.isHidden;
    BOOL isArchive = item.isArchive;
    
    if (item.isLooksBetterHidden)
    {
        isHidden = YES;
    }
    
    //default row text color set
    NSColor* color = [_theme cellDefaultTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
    
    //selected row text color set
    if (item.isSelected)
    {
        color = [_theme cellSelectedTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
    }
    
    //highlighted row text color set
    if (self.tableView.selectedRow == row)
    {
        if (self.tableView.panelMode == FMPanelModeSource)
        {
            color = [_theme cellHighlightedTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
        }
    }
    
    return color;
}

- (FMThemeColorKey)keyForCellTextColorForListItem:(FMPanelListItem *)item row:(NSInteger)row
{
    BOOL isDirectory = item.isDirectory;
    BOOL isHidden = item.isHidden;
    BOOL isArchive = item.isArchive;
    
    if (item.isLooksBetterHidden)
    {
        isHidden = YES;
    }

    //default row text color set
    FMThemeColorKey key = [_theme keyForCellDefaultTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
    
    //selected row text color set
    if (item.isSelected)
    {
        key = [_theme keyForCellSelectedTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
    }
    
    //highlighted row text color set
    if (self.tableView.selectedRow == row)
    {
        if (self.tableView.panelMode == FMPanelModeSource)
        {
            key = [_theme keyForCellHighlightedTextColor:isDirectory isHidden:isHidden isArchive:isArchive];
        }
    }
    
    return key;
}

- (NSDictionary *)createTextAttributesForAlign:(NSTextAlignment)alignment withColor:(NSColor *)color
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    paragraphStyle.alignment = alignment;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 0;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                paragraphStyle, NSParagraphStyleAttributeName,
                                color, NSForegroundColorAttributeName,
                                _cellFont, NSFontAttributeName,
                                [NSNumber numberWithInt:0], NSLigatureAttributeName,
                                [NSNumber numberWithInt:0], NSKernAttributeName,
                                nil];
    
    return attributes;
}

- (NSDictionary *)textAttributesForAlign:(NSTextAlignment)alignment withColor:(NSColor *)color andColorKey:(FMThemeColorKey)colorKey
{
    NSNumber *attributeKey = [NSNumber numberWithUnsignedLong:(alignment + (colorKey * 1000))];
    
    NSDictionary *attributes = [self->_cacheTextAttributes objectForKey:attributeKey];
    
    if (attributes == nil)
    {
        attributes = [self createTextAttributesForAlign:alignment withColor:color];

        [self->_cacheTextAttributes setObject:attributes forKey:attributeKey];
    }
    
    return attributes;
}

- (void)draw:(NSInteger)rowIndex clipRect:(NSRect)clipRect listItem:(FMPanelListItem *)listItem
{
    NSRect rectRow = [self.tableView rectOfRow:rowIndex];
    
    [NSGraphicsContext saveGraphicsState];

    for (int columnIndex = 0; columnIndex < self.tableView.tableColumns.count; columnIndex++)
    {
        NSCell *cell = [self.tableView preparedCellAtColumn:columnIndex row:rowIndex];

        NSRect rectColumn = [self.tableView rectOfColumn:columnIndex];

        //set highlighted row shadow
        if (self.tableView.selectedRow == rowIndex)
        {
            if (self.tableView.panelMode == FMPanelModeSource)
            {
                [self->_textShadow set];
            }
        }
        
        //process image cell
        if ([cell isKindOfClass:[NSImageCell class]])
        {
            NSImageCell *imageCell = (NSImageCell *)cell;
            
            if (imageCell != nil)
            {
                if ((listItem != nil) && listItem.isSelected)
                {
                    NSImage *image = [self createSelectedImage:self.tableView row:rowIndex];

                    [[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationNone];
                    
                    CGFloat horzOffset = ((rectColumn.size.width) * 0.5) - (image.size.width * 0.5);
                    CGFloat vertOffset = ((rectRow.size.height) * 0.5) - (image.size.height * 0.5);
                    
                    NSRect sourceRect = NSMakeRect(0, 0, image.size.width, image.size.height);
                    
                    NSRect destinRect = NSMakeRect(rectColumn.origin.x + horzOffset, rectRow.origin.y + vertOffset, image.size.width, image.size.height);
                    
                    [image drawInRect:destinRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
                }
            }
        }
        
        //process text cell
        if ([cell isKindOfClass:[NSPanelTextFieldCell class]])
        {
            NSPanelTextFieldCell *textCell = (NSPanelTextFieldCell *)cell;
        
            if (textCell != nil)
            {
                NSRect textRect = NSMakeRect(rectColumn.origin.x, rectRow.origin.y, rectColumn.size.width, rectRow.size.height);
                
                if (NSIsEmptyRect(textRect) == NO)
                {
                    textRect.origin.x += 3;
                    textRect.origin.y -= 1;
                    textRect.size.width -= 6;

                    NSColor *textColor = [NSColor whiteColor];
                    FMThemeColorKey colorKey = FMThemeColorKey_NULL;
                    
                    if (listItem != nil)
                    {
                        textColor = [self cellTextColorForListItem:listItem row:rowIndex];
                        colorKey = [self keyForCellTextColorForListItem:listItem row:rowIndex];
                    }
                    
                    NSTextAlignment alignment = _columnAlignment[columnIndex];
                    
                    NSDictionary *attributes = [self textAttributesForAlign:alignment withColor:textColor andColorKey:colorKey];
                    
                    [textCell.title drawInRect:textRect withAttributes:attributes];
                }
            }
        }
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
