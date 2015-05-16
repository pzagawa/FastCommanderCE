//
//  FMDefaultWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 25.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDefaultWindow.h"
#import "FMCustomTypes.h"
#import "AppDelegate.h"

@implementation FMDefaultWindow
{
    id _keyEventsMonitor;

    BOOL _isSheetOpen;
    NSPoint _buttonOrigin;
    CGFloat _buttonSpacing;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self->_isSheetOpen = NO;
    }
    
    return self;
}

- (void)initKeyEventsMonitor
{
    NSEvent* (^handler)(NSEvent*) = ^(NSEvent *theEvent)
    {
        NSWindow *targetWindow = theEvent.window;
        
        if (targetWindow != self)
        {
            return theEvent;
        }
        
        NSEvent *result = theEvent;
        
        //process selected keys events in child classess
        if (theEvent.keyCode == FMKeyCode_ESCAPE)
        {
            [self keyDown:theEvent];
            result = nil;
        }

        if (theEvent.keyCode == FMKeyCode_ENTER)
        {
            [self keyDown:theEvent];
            result = nil;
        }

        return result;
    };
    
    self->_keyEventsMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:handler];
}

- (void)closeKeyEventsMonitor
{
    [NSEvent removeMonitor:self->_keyEventsMonitor];
}

- (BOOL)isSheetOpen
{
    return self->_isSheetOpen;
}

- (void)actionCancel:(id)sender
{
    [self.btnCancel setEnabled:NO];
    [self.btnAccept setEnabled:NO];
}

- (void)actionAccept:(id)sender
{
    [self closeSheet];
}

- (void)reset
{
    //get default button spacing for manual buttons alignment in child classess
    if (_buttonSpacing == 0)
    {
        self->_buttonOrigin = self.btnAccept.frame.origin;
        self->_buttonSpacing = self.btnAccept.frame.origin.x - self.btnCancel.frame.origin.x;
    }
    
    [self.btnCancel setEnabled:YES];
    [self.btnAccept setEnabled:YES];
    
    [self.btnAccept setTitle:self.acceptTitle];
}

- (NSPoint)buttonOrigin
{
    return self->_buttonOrigin;
}

- (CGFloat)buttonSpacing
{
    return self->_buttonSpacing;
}

- (NSString *)acceptTitle
{
    return @"Close";
}

- (void)beforeStart
{
    [self makeFirstResponder:self.btnAccept];
}

- (void)closeSheet
{
    FMDefaultWindow *sheet = self;
    
    [self reset];
    
    [NSApp endSheet:sheet];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    self->_isSheetOpen = NO;
    
    AppDelegate.this.mainViewController.activeDefaultSheet = nil;

    [sheet orderOut:self];
}

+ (void)showSheetWith:(FMDefaultWindow *)window
{
    NSWindow *parentWindow = AppDelegate.this.mainViewController.window;
    
    window->_isSheetOpen = YES;
    
    AppDelegate.this.mainViewController.activeDefaultSheet = window;

    [window reset];

    [NSApp beginSheet:window modalForWindow:parentWindow modalDelegate:window didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

@end
