//
//  FMAdvancedComboSheetController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 18.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMAdvancedComboSheetController.h"
#import "FMAdvancedCombo.h"
#import "FMAdvancedComboSheetItem.h"
#import "FMAdvancedComboEvents.h"
#import "FMCustomTypes.h"

@implementation FMAdvancedComboSheetController
{
    CGFloat _itemHeight;
    int _bottomBarHeight;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if (self)
    {
        _maxListItemsCount = 10;

        _itemHeight = 50;
        
        _listItems = [NSArray array];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    _bottomBarHeight = (self.window.frame.size.height - self.scrollView.frame.size.height);
    
    //set container size
    NSSize contentSize = NSMakeSize(self.itemWidth, self.heightForContent);
    
    [self.scrollViewContainer setFrameSize:contentSize];

    //init scroll view
    [self.scrollView setLineScroll:_itemHeight];
    
    //create and position items
    float posY = self.heightForContent - _itemHeight;
    
    for (NSString *item in _listItems)
    {
        [self addListItem:item atPosY:posY];
        
        posY -= _itemHeight;
    }
    
    //set scroll pos
    if (_listItems.count > _maxListItemsCount)
    {
        NSPoint point = NSMakePoint(0, self.heightForContent);
        [self.scrollView.documentView scrollPoint:point];
    }

    //refresh list
    [self.scrollViewContainer setNeedsLayout:YES];
    [self.scrollView setNeedsLayout:YES];
}

- (void)addListItem:(NSString *)description atPosY:(float)posY
{
    NSRect rect = NSMakeRect(0, 0, self.itemWidth, _itemHeight);
    
    FMAdvancedComboSheetItem *item = [[FMAdvancedComboSheetItem alloc] initWithFrame:rect];
    
    item.controller = self;
    
    item.description = description;

    [item setHidden:YES];

    //add item to container as subview
    [self.scrollViewContainer addSubview:item];
    
    //position view in container
    NSPoint itemOrigin = NSMakePoint(0, posY);
    
    [item setFrameOrigin:itemOrigin];
    
    [item setHidden:NO];
    
    [item setNeedsDisplay:YES];
}

- (float)itemWidth
{
    return self.linkedCombo.frame.size.width;
}

- (NSUInteger)heightForContent
{
    return _listItems.count * _itemHeight;
}

- (NSUInteger)subViewsCount
{
    return self.scrollViewContainer.subviews.count;
}

- (int)listContentHeight
{
    return self.subViewsCount * _itemHeight;
}

- (int)totalSheetHeight
{
    NSUInteger count = self.subViewsCount;
    
    if (count > self.maxListItemsCount)
    {
        count = self.maxListItemsCount;
    }

    int contentHeight = count * _itemHeight;
    
    return contentHeight + _bottomBarHeight;
}

- (void)closeList
{
    __weak FMAdvancedCombo *combo = self.linkedCombo;

    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        [combo closeList];
    }];
    
    [NSOperationQueue.mainQueue addOperation:operation];
}

- (int)selectedItemIndex
{
    NSArray *items = self.scrollViewContainer.subviews;
    
    for (int index = 0; index < items.count; index++)
    {
        FMAdvancedComboSheetItem *item = items[index];
        
        if (item.isSelected)
        {
            return index;
        }
    }

    return -1;
}
    
- (void)setSelectedItemIndex:(int)value
{
    NSArray *items = self.scrollViewContainer.subviews;
    
    for (int index = 0; index < items.count; index++)
    {
        FMAdvancedComboSheetItem *item = items[index];

        item.isSelected = NO;
        
        if (value == index)
        {
            item.isSelected = YES;
        }

        [item setNeedsDisplay:YES];
    }

    [self.scrollViewContainer setNeedsDisplay:YES];
}

- (BOOL)isSelection
{
    if (self.selectedItemIndex == -1)
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)selectedItem
{
    FMAdvancedComboSheetItem *item = [self itemAtIndex:self.selectedItemIndex];
    
    if (item == nil)
    {
        return nil;
    }

    return item.text;
}

- (void)showItemAtIndex:(NSUInteger)itemIndex
{
    FMAdvancedComboSheetItem *item = [self itemAtIndex:itemIndex];
    
    if (item != nil)
    {
        [self.scrollViewContainer scrollRectToVisible:item.frame];
    }
}

- (FMAdvancedComboSheetItem *)itemAtIndex:(NSUInteger)itemIndex
{
    if (itemIndex == -1)
    {
        return nil;
    }
    
    NSArray *items = self.scrollViewContainer.subviews;
    
    for (int index = 0; index < items.count; index++)
    {
        FMAdvancedComboSheetItem *item = items[index];
     
        if (itemIndex == index)
        {
            return item;
        }
    }

    return nil;
}

- (int)indexOfClickedItem:(NSEvent *)event
{
    NSArray *items = self.scrollViewContainer.subviews;
    
    NSPoint clickLocation = [self.scrollViewContainer convertPoint:event.locationInWindow fromView:nil];
    
    for (int index = 0; index < items.count; index++)
    {
        FMAdvancedComboSheetItem *item = items[index];
        
        BOOL itemHit = NSPointInRect(clickLocation, item.frame);
        
        if (itemHit)
        {
            return index;
        }
    }
    
    return -1;
}

- (void)mouseDown:(NSEvent *)event
{
    //select clicked item
    int index = [self indexOfClickedItem:event];
    
    if (index == -1)
    {
        [super mouseDown:event];
        return;
    }
    
    self.selectedItemIndex = index;
}

- (void)mouseUp:(NSEvent *)event
{
    //select clicked item
    int index = [self indexOfClickedItem:event];
    
    if (index == -1)
    {
        [super mouseDown:event];
        return;
    }
    
    if (index == self.selectedItemIndex)
    {
        [self.linkedCombo.eventsDelegate onAdvancedComboListItemSelected:self.linkedCombo item:self.selectedItem];

        [self closeList];
    }
}

//KEY DOWN
- (void)moveDown:(id)sender
{
    int index = self.selectedItemIndex;
    
    if (index == -1)
    {
        NSUInteger value = 0;
        
        self.selectedItemIndex = (int)value;
        
        [self showItemAtIndex:value];
    }
    else
    {
        if (index < self.subViewsCount - 1)
        {
            NSUInteger value = index + 1;
            
            self.selectedItemIndex = (int)value;

            [self showItemAtIndex:value];
        }
    }
}

//KEY UP
- (void)moveUp:(id)sender
{
    int index = self.selectedItemIndex;

    if (index > 0)
    {
        NSUInteger value = index - 1;
 
        self.selectedItemIndex = (int)value;

        [self showItemAtIndex:value];
    }
    
    if (index == -1)
    {
        NSUInteger value = self.subViewsCount - 1;;

        self.selectedItemIndex = (int)value;

        [self showItemAtIndex:value];
    }
}

@end
