//
//  FMLeftDirectoryViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 07.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMLeftDirectoryViewController.h"
#import "FMPanelListItem.h"

@implementation FMLeftDirectoryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.panelSide = FMPanelSideL;
    }
    
    return self;
}

- (IBAction)onDirectoryUp:(id)sender
{
    [self commandDirectoryUp];
}

- (IBAction)onSelectItemsPopover:(id)sender
{
    [self commandShowSelectionPanel:FMSelectionMode_SELECT withPattern:self.tableView.getDefaultGlobPattern];
}

- (IBAction)actionOpenDirectoryList:(id)sender
{
    [super actionOpenDirectoryList:sender];
}
    
- (IBAction)onResetSortMode:(id)sender
{
    [super resetSortMode];
}

//FMAdvancedCombo delegates
- (void)onAdvancedComboListDidClose:(FMAdvancedCombo *)combo
{
    [super onAdvancedComboListDidClose:combo];

    [self.tableView setNeedsDisplay:YES];
}

@end
