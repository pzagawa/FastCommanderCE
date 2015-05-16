//
//  FMOperationWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationWindow.h"
#import "FMCustomTypes.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"

@implementation FMOperationWindow
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

- (void)updateAcceptButton
{
    if (self.fileOperation.isPaused)
    {
        [self.btnAccept setTitle:@"Resume"];
        [self onOperationPause:YES];
    }
    else
    {
        [self.btnAccept setTitle:@"Pause"];
        [self onOperationPause:NO];
    }
}

- (void)onOperationPause:(BOOL)pauseState
{
}

- (void)actionCancel:(id)sender
{
    [self.fileOperation requestCancel];
    
    [self.btnCancel setEnabled:NO];
    [self.btnAccept setEnabled:NO];
}

- (void)actionAccept:(id)sender
{
    if (self.fileOperation.isPaused)
    {
        [self.fileOperation requestResume];
    }
    else
    {
        [self.fileOperation requestPause];
    }
    
    [self updateAcceptButton];
}

//FMFileOperationProgress protocol
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
    return @"Start";
}

- (void)beforeStart
{
    [self makeFirstResponder:self.btnAccept];
}

- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem
{
}

- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData
{
    
}

- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData
{
    
}

- (void)itemStart:(FMFileItem *)fileItem
{
}

- (void)itemStart:(FMFileItem *)fileItem withData:(NSData *)fileData
{
}

- (void)itemStart:(FMFileItem *)fileItem withStream:(NSInputStream *)fileStream
{
}

- (void)itemProgress:(FMFileItem *)fileItem
{
}

- (void)itemFinish:(FMFileItem *)fileItem
{
}

- (void)itemError:(FMFileItem *)fileItem
{
    [self updateAcceptButton];
}

- (void)afterFinish
{
}

- (void)closeSheet
{
    FMOperationWindow *sheet = self;
    
    [self reset];
    
    [NSApp endSheet:sheet];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    self.fileOperation.progressDelegate = nil;
    
    self->_isSheetOpen = NO;

    AppDelegate.this.mainViewController.activeOperationSheet = nil;
    
    [sheet orderOut:self];
}

+ (void)showSheetWith:(FMOperationWindow *)window forOperation:(FMFileOperation *)fileOperation
{
    NSWindow *parentWindow = AppDelegate.this.mainViewController.window;
    
    window.fileOperation = fileOperation;
    window.fileOperation.progressDelegate = window;
    
    window->_isSheetOpen = YES;
    
    AppDelegate.this.mainViewController.activeOperationSheet = window;
    
    [window reset];
    
    [NSApp beginSheet:window modalForWindow:parentWindow modalDelegate:window didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

@end
