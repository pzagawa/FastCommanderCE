//
//  FMAdvancedCombo.h
//  FastCommander
//
//  Created by Piotr Zagawa on 18.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMAdvancedComboSheetController.h"
#import "FMAdvancedComboEvents.h"

@interface FMAdvancedCombo : NSTextField <NSControlTextEditingDelegate>

@property NSArray *listItems;

@property (readonly) BOOL isListVisible;

@property (weak) id<FMAdvancedComboEvents> eventsDelegate;

@property (weak) NSWindow *parentWindow;

- (void)showList;
- (void)closeList;

- (void)acceptSelectedItem;
- (BOOL)isSelection;

@end
