//
//  FMSelectionViewController.h
//
//  Created by Piotr Zagawa on 20.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMCustomTypes.h"

@interface FMSelectionViewController : NSViewController <NSPopoverDelegate>

@property (weak) IBOutlet NSSegmentedControl *btnSelectionMode;
@property (weak) IBOutlet NSTokenField *editPattern;

@property (weak) NSPopover *popOver;
@property FMPanelSide panelSide;
@property FMSelectionMode mode;
@property NSString *pattern;

- (IBAction)actionOnPatternChange:(id)sender;

- (void)showPopover:(NSPopover *)popOver sender:(id)sender panelSide:(FMPanelSide)panelSide selectionMode:(FMSelectionMode)mode pattern:(NSString *)pattern;

@end
