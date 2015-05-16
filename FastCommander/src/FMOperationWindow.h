//
//  FMOperationWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMFileOperationProgress.h"

@class FMOperationWindow;
@class FMFileOperation;
@class FMFileOperationUserData;

@interface FMOperationWindow : NSWindow <FMFileOperationProgress>

@property (weak) NSTextField *textTitle;
@property (weak) NSButton *btnCancel;
@property (weak) NSButton *btnAccept;

@property (readonly) NSPoint buttonOrigin;
@property (readonly) CGFloat buttonSpacing;

@property (weak) FMFileOperation *fileOperation;

@property (readonly) BOOL isSheetOpen;

@property (readonly) NSString *acceptTitle;

- (void)actionCancel:(id)sender;
- (void)actionAccept:(id)sender;

- (void)initKeyEventsMonitor;
- (void)closeKeyEventsMonitor;

//FMFileOperationProgress protocol
- (void)reset;
- (void)beforeStart;
- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem;
- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData;
- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData;
- (void)itemStart:(FMFileItem *)fileItem;
- (void)itemStart:(FMFileItem *)fileItem withData:(NSData *)fileData;
- (void)itemStart:(FMFileItem *)fileItem withStream:(NSInputStream *)fileStream;
- (void)itemProgress:(FMFileItem *)fileItem;
- (void)itemFinish:(FMFileItem *)fileItem;
- (void)itemError:(FMFileItem *)fileItem;
- (void)afterFinish;

- (void)onOperationPause:(BOOL)pauseState;

- (void)closeSheet;

+ (void)showSheetWith:(FMOperationWindow *)window forOperation:(FMFileOperation *)fileOperation;

@end
