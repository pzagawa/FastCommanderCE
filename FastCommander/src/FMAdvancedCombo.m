//
//  FMAdvancedCombo.m
//  FastCommander
//
//  Created by Piotr Zagawa on 18.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMAdvancedCombo.h"
#import "FMAdvancedComboSheet.h"

@implementation FMAdvancedCombo
{
    FMAdvancedComboSheetController *_windowController;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _windowController = nil;
        
        [self setDelegate:(id)self];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _windowController = nil;

        [self setDelegate:(id)self];
    }
    
    return self;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    //CATCH ENTER
    if (command == NSSelectorFromString(@"insertNewline:"))
    {
        [self.eventsDelegate onAdvancedComboTextAccepted:self item:self.stringValue];
        
        [self closeList];
        return YES;
    }

    //CATCH ESCAPE
    if (command == NSSelectorFromString(@"cancelOperation:"))
    {
        [self closeList];
        return YES;
    }

    //CATCH DOWN
    if (command == NSSelectorFromString(@"moveDown:"))
    {
        [self showList];
        return YES;
    }

    //CATCH UP
    if (command == NSSelectorFromString(@"moveUp:"))
    {
        [self showList];
        return YES;
    }

    return NO;
}

- (BOOL)isListVisible
{
    if (_windowController == nil)
    {
        return NO;
    }

    return YES;
}

- (BOOL)isSelection
{
    return _windowController.isSelection;
}

- (void)acceptSelectedItem
{
    if (self.isListVisible)
    {
        [self.eventsDelegate onAdvancedComboListItemSelected:self item:_windowController.selectedItem];
    }
}

- (void)showList
{
    if (self.isListVisible)
    {
        return;
    }
    
    [self.eventsDelegate onAdvancedComboListWillOpen:self];
    
    _windowController = [[FMAdvancedComboSheetController alloc] initWithWindowNibName:@"FMAdvancedComboSheetController"];
    
    _windowController.linkedCombo = self;
    
    _windowController.listItems = _listItems;
    
    FMAdvancedComboSheet *sheet = (FMAdvancedComboSheet *)_windowController.window;
    
    sheet.linkedCombo = self;

    [sheet setParentWindow:self.parentWindow];
    
    NSRect frameRelativeToWindow = [self convertRect:self.visibleRect toView:nil];
    
    NSRect comboRect = [self.parentWindow convertRectToScreen:frameRelativeToWindow];
    
    CGFloat sheetHeight = _windowController.totalSheetHeight;
    
    CGFloat posY = comboRect.origin.y - sheetHeight;
    
    NSRect sheetFrame = NSMakeRect(comboRect.origin.x + 1, posY, comboRect.size.width - 2, sheetHeight);
    
    [sheet setFrame:sheetFrame display:YES];
    
    [sheet makeKeyAndOrderFront:self];

    [self.parentWindow makeFirstResponder:sheet];

    [self.eventsDelegate onAdvancedComboListDidOpen:self];

    [NSApp runModalForWindow:sheet];
}

- (void)closeList
{
    [NSApp stopModalWithCode:NSOKButton];

    if (self.isListVisible)
    {
        NSWindow *sheet = _windowController.window;

        [sheet close];

        [self.eventsDelegate onAdvancedComboListDidClose:self];
        
        _windowController = nil;
    }
}

@end
