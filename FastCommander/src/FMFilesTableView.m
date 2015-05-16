//
//  FMFilesTableView.m
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFilesTableView.h"
#import "FMFilesTableView+Commands.h"
#import "FMSettings.h"
#import "FMCommandManager.h"
#import "FMThemeManager.h"
#import "FMCustomTypes.h"
#import "FMPanelListItem.h"
#import "FMPanelListProvider.h"
#import "FMReloadData.h"
#import "NSPanelTextFieldCell.h"
#import "FMFilesTableViewDrawRow.h"
#import "FMFilesTableView+Commands.h"
#import "FMContextMenu.h"

@implementation FMFilesTableView
{
    FMContextMenu *_contextMenu;

    FMTheme *_theme;
    
    NSString *_highlightStateName;
    NSNumber *_highlightStateIndex;
    NSNumber *_selectionFirstIndex;
    
    FMFilesTableViewDrawRow *_drawRow;
}

@synthesize panelSide;
@synthesize panelMode;
@synthesize listProvider;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self->_contextMenu = [[FMContextMenu alloc] init];

        [self updateTheme];

        self->_drawRow = [[FMFilesTableViewDrawRow alloc] init];
        self->_drawRow.tableView = self;
        
        //observe theme change
        [FMThemeManager.instance addObserver:self forKeyPath:@"theme" options:0 context:nil];
        
        //set double click event
        [self setDoubleAction:@selector(doubleActionEvent:)];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == FMThemeManager.instance)
    {
        if ([keyPath isEqualToString:@"theme"])
        {
            [self updateTheme];
            
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)updateTheme
{
    self->_theme = FMThemeManager.instance.theme;

    self.backgroundColor = _theme.listBackground;
    self.gridColor = _theme.listBackground;
    
    [self->_drawRow updateTheme];
}

- (void)doubleActionEvent:(id)target
{
    NSInteger rowIndex = self.clickedRow;

    if (rowIndex != -1)
    {
        [self processEnterCommmand];
    }
}

- (NSMenu *)menuForEvent:(NSEvent*)event
{
    //set first responder if required
    if (self.window.firstResponder != self)
    {
        [self.window makeFirstResponder:self];
    }

    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    NSInteger rowIndex = [self rowAtPoint:point];
    
    if (rowIndex != -1)
    {
        //highlight row
        [self highlightTableRow:rowIndex];

        //update ui immediately
        [self processUiMessages];
        
        //show context menu if required
        FMPanelListItem *listItem = [self getSelectedPanelListItem];
        
        if (listItem != nil)
        {
            if (listItem.itemType == FMPanelListItemTypeDefault)
            {
                //check provider
                if ([self.listProvider supportsContextMenu:listItem])
                {
                    return [_contextMenu menuForItem:listItem];
                }
            }
        }
    }

    return nil;
}

- (void)processUiMessages
{
    NSDate *dtr = [[NSDate alloc] initWithTimeIntervalSinceNow:0.2];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dtr];
}

- (void)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    NSMutableArray *items = [listProvider getListItemsForOperation];
    
    if (items.count > 0)
    {
        [pb clearContents];

        NSMutableString *paths = [[NSMutableString alloc] init];
        
        int index = 1;
        
        for (FMPanelListItem *listItem in items)
        {
            [paths appendString:listItem.unifiedFilePath];
            
            if (index < items.count)
            {
                [paths appendString:@"\n"];
            }

            index++;
        }

        [pb writeObjects:[NSArray arrayWithObject:paths]];
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([self handleKeyDown:theEvent] == YES)
    {
        return;
    }
    
    [super keyDown:theEvent];
}

- (BOOL)handleKeyDown:(NSEvent *)theEvent
{
    //TAB KEY
    if (theEvent.keyCode == FMKeyCode_TAB)
    {
        [self processSwitchPanelCommmand];
        
        return YES;
    }
    
    //SPACE KEY
    if (theEvent.keyCode == FMKeyCode_SPACE)
    {            
        [self processSelectionCommmand];

        return YES;
    }
    
    //ENTER KEY
    if (theEvent.keyCode == FMKeyCode_ENTER)
    {
        if ([self processEnterCommmand])
        {
            return YES;
        }
    }

    //BACKSPACE KEY
    if (theEvent.keyCode == FMKeyCode_BACKSPACE)
    {
        if ([self processDirectoryUpCommmand])
        {
            return YES;
        }
    }

    //DELETE KEY
    if (theEvent.keyCode == FMKeyCode_DELETE)
    {
        if ([self processFileOperationDelete])
        {
            return YES;
        }
    }

    //SHOW DIRECTORIES LIST
    if ((theEvent.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask)
    {
        FMPanelSide side = 0;
        
        //left panel
        if (theEvent.keyCode == FMKeyCode_1)
        {
            side = FMPanelSideL;
        }
        
        //right panel
        if (theEvent.keyCode == FMKeyCode_2)
        {
            side = FMPanelSideR;
        }
        
        if ([self processShowDirectoriesCommmandForPanel:side])
        {
            return YES;
        }
    }
    
    //PAGE UP
    if (theEvent.keyCode == FMKeyCode_PageUp)
    {
        [self selectRowPageUp];
        return YES;
    }
    
    //PAGE DOWN
    if (theEvent.keyCode == FMKeyCode_PageDown)
    {
        [self selectRowPageDown];
        return YES;
    }

    //HOME
    if (theEvent.keyCode == FMKeyCode_Home)
    {
        [self selectFirstListRow];
        return YES;
    }

    //END
    if (theEvent.keyCode == FMKeyCode_End)
    {
        [self selectLastListRow];
        return YES;
    }

    //SELECTION: select
    if (theEvent.keyCode == FMKeyCode_Plus)
    {
        [self processShowSelectionPanelCommmand:FMSelectionMode_SELECT withPattern:self.getDefaultGlobPattern];
        return YES;
    }
    
    //SELECTION: unselect
    if (theEvent.keyCode == FMKeyCode_Minus)
    {
        [self processShowSelectionPanelCommmand:FMSelectionMode_UNSELECT withPattern:self.getDefaultGlobPattern];
        return YES;
    }
    
    //SELECTION: invert
    if (theEvent.keyCode == FMKeyCode_Asterisk)
    {
        [self processAllItemsInvertCommand];
        return YES;
    }
    
    return NO;
}

- (void)keyUp:(NSEvent *)theEvent
{
    if ([self handleKeyUp:theEvent] == YES)
    {
        return;
    }
    
    [super keyUp:theEvent];
}

- (BOOL)handleKeyUp:(NSEvent *)theEvent
{
    return NO;
}

- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
    //custom selection color fill
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
    NSRange visibleRowIndexes = [self rowsInRect:theClipRect];
    NSInteger selectedRowIndex = visibleRowIndexes.location;
    NSInteger endRowIndex = selectedRowIndex + visibleRowIndexes.length;
    
    [NSGraphicsContext saveGraphicsState];

    // draw highlight for the visible, selected rows
    for (; selectedRowIndex < endRowIndex; selectedRowIndex++)
    {
        //source, focused panel
        if (self.panelMode == FMPanelModeSource)
        {
            if ([selectedRowIndexes containsIndex:selectedRowIndex])
            {
                [_theme.listHighlightedRow setFill];
                
                NSRect rowRect = [self rectOfRow:selectedRowIndex];
                NSRectFill(rowRect);
            }
        }
        
        //target, unfocused panel
        if (self.panelMode == FMPanelModeTarget)
        {
            if ([selectedRowIndexes containsIndex:selectedRowIndex])
            {
                //draw highlight background only for selected items
                FMPanelListItem *fileItem = [self getPanelListItem:selectedRowIndex];
                
                if (fileItem.isSelected)
                {
                    [_theme.listSelectedRow setFill];
                    
                    NSRect rowRect = [self rectOfRow:selectedRowIndex];
                    NSRectFill(rowRect);
                }
            }
        }
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (int)getTotalRowHeight
{
    return self.rowHeight + self.intercellSpacing.height;
}

- (int)getViewItemsCount
{
    NSRect rect = self.visibleRect;
    
    return (rect.size.height / [self getTotalRowHeight]);
}

- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect
{
    [self drawRowSelection:rowIndex];
    
    //custom row cells drawing
    FMPanelListItem *listItem = [self getPanelListItem:rowIndex];
    
    [self->_drawRow draw:rowIndex clipRect:clipRect listItem:listItem];
}

- (void)drawRowSelection:(NSInteger)rowIndex
{
    if ([listProvider isLoadingData])
    {
        return;
    }

    if (self.selectedRow != rowIndex)
    {
        //draw custom background for selected panel item
        NSMutableArray *items = [listProvider getListItems];
        
        if (items && items.count > 0)
        {
            //#BUG001 test if refresh before internal count update
            if (rowIndex >= items.count)
            {
                return;
            }
            
            FMPanelListItem *fileItem = [self getPanelListItem:rowIndex];
            
            if (fileItem.isSelected)
            {
                NSRect rowRect = [self rectOfRow:rowIndex];
                
                [NSGraphicsContext saveGraphicsState];
                
                [_theme.listSelectedRow setFill];
                
                NSRectFill(rowRect);
                
                [NSGraphicsContext restoreGraphicsState];
            }
        }
    }

    return;
}

- (void)toggleRowSelect:(NSInteger)row
{
    FMPanelListItem *fileItem = [self getPanelListItem:row];
    
    //allow selection for default list item types only
    if (fileItem.itemType == FMPanelListItemTypeDefault)
    {
        [fileItem setSelected:!fileItem.isSelected];
        
        //refresh first column (selection image)
        [self reloadColumn:0 row:row];
    }
}

- (void)toggleItemSelection
{
    NSInteger row = self.selectedRow;
    
    if (row != -1)
    {
        //select list item
        [self toggleRowSelect:row];
        
        //select next row
        [self highlightTableRow:row + 1];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)reloadColumn:(NSInteger)column row:(NSInteger)row
{
    NSIndexSet *rowsToProcess = [NSIndexSet indexSetWithIndex:row];
    NSIndexSet *colsToProcess = [NSIndexSet indexSetWithIndex:column];
    
    [self reloadDataForRowIndexes:rowsToProcess columnIndexes:colsToProcess];
}

- (void)reloadColumnsForRow:(NSInteger)row
{
    NSIndexSet *rowsToProcess = [NSIndexSet indexSetWithIndex:row];
    
    NSIndexSet *colsToProcess = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfColumns])];

    [self reloadDataForRowIndexes:rowsToProcess columnIndexes:colsToProcess];
}

- (void)selectFirstListRow
{
    [self highlightTableRow:0];
}

- (void)selectLastListRow
{
    NSInteger numberOfRows = [self numberOfRows];
    
    [self highlightTableRow:(numberOfRows - 1)];
}

- (void)selectRowPageUp
{
    int pageItemsCount = [self getViewItemsCount] - 1;
    
    NSRange visibleRowIndexes = [self rowsInRect:self.visibleRect];
    
    NSInteger rowIndex = visibleRowIndexes.location - pageItemsCount;
    
    [self highlightTableRow:rowIndex];
}

- (void)selectRowPageDown
{
    int pageItemsCount = [self getViewItemsCount] - 1;

    NSRange visibleRowIndexes = [self rowsInRect:self.visibleRect];
    
    NSInteger rowIndex = visibleRowIndexes.location + (visibleRowIndexes.length - 1) + pageItemsCount;
    
    [self highlightTableRow:rowIndex];
}

- (void)highlightTableRow:(NSInteger)row
{
    if (row < 0)
    {
        row = 0;
    }
    
    NSInteger numberOfRows = [self numberOfRows];
    
    if (numberOfRows > 0)
    {
        if (row > (numberOfRows - 1))
        {
            row = numberOfRows - 1;
        }

        NSIndexSet *rowsToSelect = [NSIndexSet indexSetWithIndex:row];

        [self selectRowIndexes:rowsToSelect byExtendingSelection:NO];

        //scroll to show selection
        [self scrollRowToVisible:row];
    }
}

- (FMPanelListItem *)getPanelListItem:(NSInteger)rowIndex
{
    NSMutableArray *items = [listProvider getListItems];
    
    if (items && items.count > 0)
    {
        if (rowIndex < items.count)
        {
            return [items objectAtIndex:rowIndex];
        }
    }
    
    return nil;
}

- (FMPanelListItem *)getSelectedPanelListItem
{
    NSInteger row = self.selectedRow;
    
    if (row != -1)
    {
        return [self getPanelListItem:row];
    }

    return nil;
}

- (NSString *)getSelectedListItemName
{
    FMPanelListItem *listItem = [self getSelectedPanelListItem];

    if (listItem != nil)
    {
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            return listItem.fileName;
        }
    }
    
    return nil;
}

- (void)selectFirstItem
{
    [self.window makeFirstResponder:self];

    //select first row
    [self highlightTableRow:0];
}

- (NSInteger)getPanelListItemIndexByName:(NSString *)value
{
    if (value != nil)
    {
        NSMutableArray *items = [listProvider getListItems];
        
        if (items != nil)
        {
            for (int index = 0; index < items.count; index++)
            {
                FMPanelListItem *listItem = [items objectAtIndex:index];
                
                if (listItem.itemType == FMPanelListItemTypeDefault)
                {
                    if ([listItem.fileName localizedCompare:value] == NSOrderedSame)
                    {
                        return index;
                    }
                }
            }
        }
    }
    
    return -1;
}

- (NSNumber *)getPanelListItemFirstSelectedIndex
{
    NSMutableArray *items = [listProvider getListItems];
    
    if (items)
    {
        for (int index = 0; index < items.count; index++)
        {
            FMPanelListItem *listItem = [items objectAtIndex:index];
            
            if (listItem.isSelected)
            {
                return [NSNumber numberWithInteger:index];
            }
        }
    }
    
    return nil;
}

- (void)selectListItemByName:(NSString *)value
{
    NSInteger rowIndex = [self getPanelListItemIndexByName:value];

    if (rowIndex == -1)
    {
        //select first row
        [self highlightTableRow:0];
    }
    else
    {
        [self highlightTableRow:rowIndex];        
    }    
}

- (void)saveListHighlightState
{
    self->_highlightStateName = [self.getSelectedListItemName copy];
    self->_highlightStateIndex = [NSNumber numberWithInteger:self.selectedRow];
    self->_selectionFirstIndex = [self.getPanelListItemFirstSelectedIndex copy];
}

- (void)restoreListHighlightState:(FMReloadData *)data
{
    if (data.nameToSelectOnList != nil)
    {
        self->_highlightStateName = data.nameToSelectOnList;
    }

    if (self->_highlightStateName != nil)
    {
        NSInteger rowIndex = [self getPanelListItemIndexByName:_highlightStateName];
        
        if (rowIndex == -1)
        {
            if (self->_selectionFirstIndex == nil)
            {
                if (self->_highlightStateIndex == nil)
                {
                    [self highlightTableRow:0];
                }
                else
                {
                    [self highlightTableRow:self->_highlightStateIndex.integerValue];
                }
            }
            else
            {
                rowIndex = self->_selectionFirstIndex.integerValue - 1;
                
                [self highlightTableRow:rowIndex];
            }
        }
        else
        {
            [self highlightTableRow:rowIndex];
        }
    }
}

- (void)processAllItemsSelection:(FMSelectionBlock)selectionBlock
{
    NSMutableArray *items = [listProvider getListItems];

    if (items)
    {
        for (int row = 0; row < items.count; row++)
        {
            FMPanelListItem *listItem = [items objectAtIndex:row];
            
            //allow selection for default list item types only
            if (listItem.itemType == FMPanelListItemTypeDefault)
            {
                selectionBlock(row, listItem);

                //refresh first column (selection image)
                [self reloadColumn:0 row:row];
            }
        }
        
        //redraw view
        [self setNeedsDisplay:YES];
    }
    
    //send select items command
    FMCommand *command = [FMCommand selectItems];
    
    command.sourceObject = self;
    command.panelSide = self.panelSide;
    
    [command execute];
}

- (void)updateListItemByFileName:(NSString *)fileName withDirectorySize:(long long)size
{
    NSMutableArray *items = [listProvider getListItems];
    
    if (items)
    {
        for (int row = 0; row < items.count; row++)
        {
            FMPanelListItem *item = [items objectAtIndex:row];
            
            if (item.isDirectory)
            {
                if ([item.unifiedFilePath isEqualToString:fileName])
                {
                    //update item directory size
                    [item setDirectorySize:size];
                    
                    //refresh columns
                    [self reloadColumnsForRow:row];

                    //redraw view
                    [self setNeedsDisplay:YES];
                    
                    return;
                }
            }
        }
    }
}

- (void)focusView
{
    [self.window makeFirstResponder:self];
}

- (BOOL)processSetPanelMode:(FMPanelMode)mode;
{
    FMCommand *command = [FMCommand setPanelMode:mode];
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        command.panelMode = mode;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (void)updateBottomStatusTextWithCurrentlySelectedListItem
{
    NSString *text = @"";
    
    if (self.window == nil)
    {
        return;
    }
    
    FMPanelListItem *listItem = [self getSelectedPanelListItem];
    
    if (listItem != nil)
    {
        text = [listItem.unifiedFilePath copy];
    }
    
    FMCommand *command = [FMCommand updateBottomStatusText:text];
    
    if (command != nil)
    {
        [command execute];
    }
}

- (BOOL)becomeFirstResponder
{
    [self processSetPanelMode:FMPanelModeSource];
    
    [self updateBottomStatusTextWithCurrentlySelectedListItem];
        
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    SEL action = item.action;

    //PASTEBOARD - COPY
    if (action == @selector(copy:))
    {
        NSMutableArray *items = [listProvider getListItemsForOperation];
        
        if (items.count > 0)
        {
            return YES;
        }
    }
    
    return [self validateMenuItemInCategory:item];
}

- (NSString *)getDefaultGlobPattern
{
    return @"*";
}

- (void)initializeSorting
{
    [self setSortDescriptors:nil];

    for (NSTableColumn *column in self.tableColumns)
    {
        [column setSortDescriptorPrototype:nil];
    }

    for (NSTableColumn *column in self.tableColumns)
    {
        if ([column.identifier isEqualToString:@"colAttributes"])
        {
            continue;
        }

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column.identifier ascending:YES];
        
        [column setSortDescriptorPrototype:sortDescriptor];
    }
}

@end
