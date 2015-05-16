//
//  FMPreferencesWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 25.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPreferencesWindow.h"
#import "AppDelegate.h"
#import "FMThemeManager.h"
#import "FMSettings.h"
#import "FMBookmarksManager.h"
#import "NSString+Utils.h"
#import "FMOSTools.h"

@implementation FMPreferencesWindow
{
    FMBookmarksManager *_bookmarksManager;
    NSArray *_bookmarks;
}

static NSString *BOOKMARK_DRAG_DROP_DATATYPE = @"BookmarkDragDropDataType";

- (void)actionAccept:(id)sender
{
    [super actionAccept:sender];
}

- (void)reset
{
    [super reset];
    
    self->_bookmarksManager = [[FMBookmarksManager alloc] init];

    [_bookmarksManager update];
    
    self->_bookmarks = [_bookmarksManager loadBookmarks];

    if (self.selectTab == FMShowPreferencesTabDefault)
    {
        [self.tabView selectFirstTabViewItem:self];
    }
    else
    {
        if (self.selectTab == FMShowPreferencesTabBookmarks)
        {
            [self.tabView selectTabViewItemWithIdentifier:@"bookmarks"];
        }
    }

    self.textTitle.stringValue = @"PREFERENCES";
    
    self.editBookmarkDirectory.stringValue = [AppDelegate.this.sourcePanelListProvider.currentPath copy];
    
    [self.tableThemes reloadData];
    [self.tableBookmarks reloadData];
    
    [self selectTableRowForCurrentTheme];
    
    [self.tableBookmarks registerForDraggedTypes:[NSArray arrayWithObject:BOOKMARK_DRAG_DROP_DATATYPE]];

    self.checkUseTrash.state = FMSettings.instance.isUseTrash ? NSOnState : NSOffState;
}

- (void)selectTableRowForCurrentTheme
{
    NSUInteger themeIndex = [FMThemeManager.instance themeIndexByName:FMThemeManager.instance.theme.themeName];
    
    if (themeIndex != -1)
    {
        [self selectRow:themeIndex ofTable:self.tableThemes];
    }
}

- (void)selectRow:(NSInteger)row ofTable:(NSTableView *)tableView
{
    if (tableView == self.tableThemes)
    {
        if (row < 0)
        {
            row = 0;
        }
        
        NSInteger numberOfRows = [tableView numberOfRows];
        
        if (numberOfRows > 0)
        {
            if (row > (numberOfRows - 1))
            {
                row = numberOfRows - 1;
            }
            
            NSIndexSet *rowsToSelect = [NSIndexSet indexSetWithIndex:row];
            
            [tableView selectRowIndexes:rowsToSelect byExtendingSelection:NO];
            
            [tableView scrollRowToVisible:row];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.tableThemes)
    {
        return FMThemeManager.instance.themesCount;
    }

    if (tableView == self.tableBookmarks)
    {
        return self->_bookmarks.count;
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.tableThemes)
    {
        if ([tableColumn.identifier isEqualToString:@"colThemeName"])
        {
            FMTheme *theme = [FMThemeManager.instance themeByIndex:row];
            
            NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:theme.themeName];

            return cell;
        }
    }

    if (tableView == self.tableBookmarks)
    {
        FMBookmarkItem *bookmark = [self->_bookmarks objectAtIndex:row];
        
        if ([tableColumn.identifier isEqualToString:@"colVisible"])
        {
            NSButtonCell *cell = [[NSButtonCell alloc] init];

            [cell setState:bookmark.isVisible ? NSOnState : NSOffState];
            
            return cell;
        }
        
        if ([tableColumn.identifier isEqualToString:@"colPath"])
        {
            NSString *path = bookmark.path;
            
            NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:path];

            return cell;
        }
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (notification != nil)
    {
        if ([notification.name isEqualToString:NSTableViewSelectionDidChangeNotification])
        {
            NSTableView *tableView = (NSTableView *)notification.object;
            
            if (tableView == self.tableThemes)
            {
                FMTheme *theme = [FMThemeManager.instance themeByIndex:tableView.selectedRow];
                
                if (theme != nil)
                {
                    [FMThemeManager.instance selectThemeByName:theme.themeName];
                }
            }
        }
    }
}

- (void)tableView:(NSTableView *)table setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (table == self.tableBookmarks)
    {
        if ([aTableColumn.identifier isEqualToString:@"colVisible"])
        {
            FMBookmarkItem *bookmark = [self->_bookmarks objectAtIndex:rowIndex];
            
            BOOL checked = [anObject boolValue];
            
            bookmark.isVisible = checked;
            
            [_bookmarksManager saveBookmarks:self->_bookmarks];
        }
    }
}

//drag and drop
- (BOOL)tableView:(NSTableView *)table writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    if (table == self.tableBookmarks)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:BOOKMARK_DRAG_DROP_DATATYPE] owner:self];
        [pboard setData:data forType:BOOKMARK_DRAG_DROP_DATATYPE];
        return YES;
    }
    
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)table validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (table == self.tableBookmarks)
    {
        if (table == [info draggingSource])
        {
            if (row > _bookmarks.count)
            {
                return NSDragOperationNone;
            }
            
            return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)table acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *rowData = [pboard dataForType:BOOKMARK_DRAG_DROP_DATATYPE];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    NSInteger sourceRowIndex = [rowIndexes firstIndex];
    
    [self moveBookmarkFromIndex:sourceRowIndex toIndex:row];

    return YES;
}

- (void)moveBookmarkFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)targetIndex
{
    NSMutableArray *bookmarksList = [NSMutableArray arrayWithArray:_bookmarks];
    
    FMBookmarkItem *bookmark = [bookmarksList objectAtIndex:sourceIndex];
    
    [bookmarksList removeObjectAtIndex:sourceIndex];
    
    if (targetIndex > bookmarksList.count)
    {
        [bookmarksList addObject:bookmark];
    }
    else
    {
        NSInteger index = targetIndex - 1;
        
        if (sourceIndex > targetIndex)
        {
            index = targetIndex;
        }
        
        [bookmarksList insertObject:bookmark atIndex:index];
    }

    self->_bookmarks = bookmarksList;
    
    [_bookmarksManager saveBookmarks:self->_bookmarks];    

    [self.tableBookmarks reloadData];
}

- (void)actionAddBookmark:(id)sender
{
    if ([_bookmarksManager addBookmark:self.editBookmarkDirectory.stringValue])
    {
        self->_bookmarks = [_bookmarksManager loadBookmarks];
        
        [self.tableBookmarks reloadData];
        
        NSInteger lastRow = self->_bookmarks.count - 1;
        
        [self.tableBookmarks scrollRowToVisible:lastRow];
        
        [self highlightBookmarkRow:lastRow];
        
        [self makeFirstResponder:self.tableBookmarks];
    }
}

- (void)highlightBookmarkRow:(NSInteger)row
{
    NSIndexSet *rowsToSelect = [NSIndexSet indexSetWithIndex:row];
    
    [self.tableBookmarks selectRowIndexes:rowsToSelect byExtendingSelection:NO];    
}

//context menu
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    SEL action = item.action;

    if (action == @selector(actionDeleteBookmark:))
    {        
        if (self.firstResponder == self.tableBookmarks)
        {
            NSInteger rowIndex = self.tableBookmarks.clickedRow;
            
            if (rowIndex != -1)
            {
                [self highlightBookmarkRow:rowIndex];
                
                return YES;
            }
        }
    }
     
    return NO;
}

- (void)actionDeleteBookmark:(id)sender
{
    NSInteger rowIndex = self.tableBookmarks.selectedRow;

    if (rowIndex != -1)
    {
        FMBookmarkItem *bookmark = [_bookmarks objectAtIndex:rowIndex];
    
        if ([_bookmarksManager removeBookmark:bookmark])
        {
            self->_bookmarks = [_bookmarksManager loadBookmarks];
        
            [self.tableBookmarks reloadData];
        }
    }
}

- (IBAction)actionChangeUseTrash:(id)sender
{
    FMSettings.instance.isUseTrash = (self.checkUseTrash.state == NSOnState);
}

//sheet
+ (void)showSheet:(FMShowPreferencesTab)tab
{
    FMPreferencesWindow *window = (FMPreferencesWindow *)AppDelegate.this.mainViewController.sheetPreferences;
    
    window.selectTab = tab;
    
    [super showSheetWith:window];
}

+ (void)close
{
    FMDefaultWindow *window = AppDelegate.this.mainViewController.sheetPreferences;
    
    [window closeSheet];
}

@end
