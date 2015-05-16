//
//  FMLeftDirectoryViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 07.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDirectoryViewController.h"
#import "FMLeftFilesTableView.h"

@interface FMLeftDirectoryViewController : FMDirectoryViewController

- (IBAction)onDirectoryUp:(id)sender;
- (IBAction)onSelectItemsPopover:(id)sender;
- (IBAction)actionOpenDirectoryList:(id)sender;
- (IBAction)onResetSortMode:(id)sender;

@end
