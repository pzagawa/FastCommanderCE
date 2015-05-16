//
//  FMAdvancedComboSheetController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 18.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMAdvancedCombo;

@interface FMAdvancedComboSheetController : NSWindowController <NSWindowDelegate>
    
@property NSArray *listItems;

@property (weak) FMAdvancedCombo *linkedCombo;

@property (readonly) int maxListItemsCount;

@property (readonly) int listContentHeight;
@property (readonly) int totalSheetHeight;
    
@property int selectedItemIndex;

@property (readonly) BOOL isSelection;

@property (readonly) NSString *selectedItem;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSView *scrollViewContainer;

@end
