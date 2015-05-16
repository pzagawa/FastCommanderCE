//
//  FMOperationSearchWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 19.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationSearchWindow : FMOperationWindow

@property (weak) IBOutlet NSButton *btnShow;
@property (weak) IBOutlet NSButton *btnClose;

@property (weak) IBOutlet NSProgressIndicator *operationProgress;

@property (weak) IBOutlet NSTextField *textSearchIn;
@property (weak) IBOutlet NSTokenField *editFilePatterns;
@property (weak) IBOutlet NSTextField *editSearchText;

@property (weak) IBOutlet NSTextField *textSearchStatus;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;
- (IBAction)actionShow:(id)sender;
- (IBAction)actionClose:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
