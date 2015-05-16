//
//  FMDirectoryViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 07.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDirectoryViewControllerContent.h"
#import "FMPanelListItem.h"
#import "FMResources.h"
#import "NSPanelTextFieldCell.h"
#import "FMThemeManager.h"

@implementation FMDirectoryViewControllerContent
{
    NSDateFormatter *_dateFormatter;
}

@synthesize listProvider;
@synthesize tableView;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_dateFormatter = [[NSDateFormatter alloc] init];
        self->_dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    }
    
    return self;    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSMutableArray *items = [self.listProvider getListItems];
    
    return items.count;
}

- (NSTextFieldCell *)createTextCell:(NSString *)title alignment:(NSTextAlignment)alignment color:(NSColor *)color
{
    if (title == nil)
    {
        title = @"";
    }

    NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:title];
    
    [cell setAlignment:alignment];
    [cell setTextColor:[NSColor whiteColor]];
    
    return cell;
}

- (NSImage *)createSelectedImage:(NSTableView *)aTableView row:(NSInteger)row
{
    NSImage *image = nil;

    if (tableView.panelMode == FMPanelModeSource)
    {
        if (tableView.selectedRow == row)
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

    if (tableView.panelMode == FMPanelModeTarget)
    {
        //show normal icon for all other rows
        image = [[FMResources instance] imageItemSelected];
    }
    
    return image;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([listProvider isLoadingData])
    {
        return nil;
    }
    
    NSMutableArray *items = [listProvider getListItems];

    if (items && items.count > 0)
    {        
        //#BUG001 test if refresh before internal count update
        if (row >= items.count)
        {
            return nil;
        }
        
        FMPanelListItem *fileItem = [items objectAtIndex:row];
        
        //row text color
        NSColor* textColor = [NSColor blackColor];
        
        //column SELECTED
        if ([tableColumn.identifier isEqualToString:@"colSelected"])
        {
            NSImage *image = nil;

            /*
            if (fileItem.isSelected)
            {
                image = [self createSelectedImage: tableView row: row];
            }
            */
            
            return image;
        }

        //column NAME
        if ([tableColumn.identifier isEqualToString:@"colName"])
        {
            return [self createTextCell: [fileItem displayFileName] alignment: NSLeftTextAlignment color:textColor];
        }

        //column SIZE
        if ([tableColumn.identifier isEqualToString:@"colSize"])
        {
            return [self createTextCell: [fileItem fileSizeText] alignment: NSRightTextAlignment  color:textColor];
        }

        //column DATE/TIME
        if ([tableColumn.identifier isEqualToString:@"colDate"])
        {
            NSString *dateText = [self->_dateFormatter stringFromDate: fileItem.modificationDate];
            
            return [self createTextCell: dateText alignment: NSRightTextAlignment color:textColor];
        }
        
        //column ATTRIBUTES
        if ([tableColumn.identifier isEqualToString:@"colAttributes"])
        {
            return [self createTextCell: [fileItem attributesText] alignment: NSRightTextAlignment color:textColor];
        }
    }
    
    return nil;
}

- (void)sortPanelListItemsByColumn:(FMSortedListItemsBy)sortBy directionASC:(BOOL)dirASC
{
    NSMutableArray *items = [listProvider getListItems];

    [self sortPanelListItems:items byColumn:sortBy directionASC:dirASC];
}

- (FMSortedListItemsBy)sortModeFromSortDescriptor:(NSSortDescriptor *)descriptor
{
    FMSortedListItemsBy sortBy = FMSortedListItemsByName;

    if ([descriptor.key isEqualToString:@"colSelected"])
    {
        sortBy = FMSortedListItemsBySelection;
    }

    if ([descriptor.key isEqualToString:@"colName"])
    {
        sortBy = FMSortedListItemsByName;
    }

    if ([descriptor.key isEqualToString:@"colSize"])
    {
        sortBy = FMSortedListItemsBySize;
    }

    if ([descriptor.key isEqualToString:@"colDate"])
    {
        sortBy = FMSortedListItemsByDate;
    }

    return sortBy;
}

- (void)sortPanelListItems:(NSMutableArray *)itemsToSort byColumn:(FMSortedListItemsBy)sortBy directionASC:(BOOL)dirASC
{
    if (sortBy == FMSortedListItemsBySelection)
    {
        [itemsToSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            FMPanelListItem *itemA = (FMPanelListItem *)obj1;
            FMPanelListItem *itemB = (FMPanelListItem *)obj2;

            NSNumber *numA = [NSNumber numberWithBool:itemA.isSelected];
            NSNumber *numB = [NSNumber numberWithBool:itemB.isSelected];

            if (itemA.itemType == FMPanelListItemTypeDirUp || itemB.itemType == FMPanelListItemTypeDirUp)
            {
                return NSOrderedSame;
            }

            if (dirASC)
            {
                return [numA compare:numB];
            }
            else
            {
                return [numB compare:numA];
            }
        }];
    }
    
    if (sortBy == FMSortedListItemsByName)
    {
        [itemsToSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            FMPanelListItem *itemA = (FMPanelListItem *)obj1;
            FMPanelListItem *itemB = (FMPanelListItem *)obj2;

            if (itemA.itemType == FMPanelListItemTypeDirUp || itemB.itemType == FMPanelListItemTypeDirUp)
            {
                return NSOrderedSame;
            }
            
            if (dirASC)
            {
                return [itemA.fileName localizedStandardCompare:itemB.fileName];
            }
            else
            {
                return [itemB.fileName localizedStandardCompare:itemA.fileName];
            }
        }];
    }
    
    if (sortBy == FMSortedListItemsBySize)
    {
        [itemsToSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            FMPanelListItem *itemA = (FMPanelListItem *)obj1;
            FMPanelListItem *itemB = (FMPanelListItem *)obj2;

            if (itemA.itemType == FMPanelListItemTypeDirUp || itemB.itemType == FMPanelListItemTypeDirUp)
            {
                return NSOrderedSame;
            }
            
            NSNumber *fileSizeA = [NSNumber numberWithLongLong:(itemA.fileSize == nil) ? 0 : itemA.fileSize.longLongValue];
            NSNumber *fileSizeB = [NSNumber numberWithLongLong:(itemB.fileSize == nil) ? 0 : itemB.fileSize.longLongValue];
            
            if (dirASC)
            {
                return [fileSizeA compare:fileSizeB];
            }
            else
            {
                return [fileSizeB compare:fileSizeA];
            }
        }];
    }
    
    if (sortBy == FMSortedListItemsByDate)
    {
        [itemsToSort sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            FMPanelListItem *itemA = (FMPanelListItem *)obj1;
            FMPanelListItem *itemB = (FMPanelListItem *)obj2;

            if (itemA.itemType == FMPanelListItemTypeDirUp || itemB.itemType == FMPanelListItemTypeDirUp)
            {
                return NSOrderedSame;
            }

            if (dirASC)
            {
                return [itemA.modificationDate compare:itemB.modificationDate];
            }
            else
            {
                return [itemB.modificationDate compare:itemA.modificationDate];
            }
        }];
    }
}

@end
