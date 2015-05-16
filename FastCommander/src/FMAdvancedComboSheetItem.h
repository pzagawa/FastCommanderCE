//
//  FMAdvancedComboSheetItem.h
//  FastCommander
//
//  Created by Piotr Zagawa on 20.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMAdvancedComboSheetController;

@interface FMAdvancedComboSheetItem : NSView

@property (weak) FMAdvancedComboSheetController *controller;

@property (readonly) NSString *text;

@property (readonly) NSString *title;

@property NSString *description;

@property NSImage *icon;

@property BOOL isSelected;

@end
