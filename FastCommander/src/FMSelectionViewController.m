//
//  FMSelectionViewController.m
//
//  Created by Piotr Zagawa on 20.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMSelectionViewController.h"
#import "FMCommand.h"
#import "FMCommandManager.h"

@implementation FMSelectionViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    
    return self;
}

- (void)showPopover:(NSPopover *)popOver sender:(id)sender panelSide:(FMPanelSide)panelSide selectionMode:(FMSelectionMode)mode pattern:(NSString *)pattern
{
    self.popOver = popOver;
    self.panelSide = panelSide;
    self.mode = mode;
    
    if (self.pattern == nil)
    {
        self.pattern = pattern;
    }
    
    [popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}

- (void)popoverWillShow:(NSNotification *)notification
{
    self.editPattern.tokenizingCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    
    [self.editPattern setStringValue:self.pattern];
    
    if (self.mode == FMSelectionMode_SELECT)
    {
        [self.btnSelectionMode setSelectedSegment:0];
    }

    if (self.mode == FMSelectionMode_UNSELECT)
    {
        [self.btnSelectionMode setSelectedSegment:1];
    }
    
    [self.editPattern becomeFirstResponder];
}

- (FMSelectionMode)getSelectionMode
{
    NSUInteger value = [self.btnSelectionMode selectedSegment];

    if (value == 0)
    {
        return FMSelectionMode_SELECT;
    }

    if (value == 1)
    {
        return FMSelectionMode_UNSELECT;
    }
    
    return FMSelectionMode_SELECT;
}

- (BOOL)updateItemsSelectionCommand
{
    self.mode = [self getSelectionMode];
    self.pattern = [self.editPattern.stringValue copy];

    FMCommand *command = [FMCommand updateItemsSelection:self.mode withPattern:self.pattern];
    
    if (command != nil)
    {
        command.sourceObject = self;
        command.panelSide = self.panelSide;
        
        [command execute];
        
        return YES;
    }
    
    return NO;
}

- (IBAction)actionOnPatternChange:(id)sender
{
    if (sender != nil)
    {
        if ([self updateItemsSelectionCommand])
        {
            [self.popOver close];
        }
    }
}

@end
