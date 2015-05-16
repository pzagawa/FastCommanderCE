//
//  FMDefaultWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 25.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMDefaultWindow : NSWindow

@property (weak) NSTextField *textTitle;
@property (weak) NSButton *btnCancel;
@property (weak) NSButton *btnAccept;

@property (readonly) NSPoint buttonOrigin;
@property (readonly) CGFloat buttonSpacing;

@property (readonly) BOOL isSheetOpen;

@property (readonly) NSString *acceptTitle;

- (void)actionCancel:(id)sender;
- (void)actionAccept:(id)sender;

- (void)initKeyEventsMonitor;
- (void)closeKeyEventsMonitor;

- (void)reset;

- (void)closeSheet;

+ (void)showSheetWith:(FMDefaultWindow *)window;

@end
