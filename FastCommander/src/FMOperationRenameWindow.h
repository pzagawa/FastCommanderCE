//
//  FMOperationRenameWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationRenameWindow : FMOperationWindow

@property (weak) IBOutlet NSButton *btnSkip;

@property (weak) IBOutlet NSTextField *editFileName;
@property (weak) IBOutlet NSView *viewError;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;
- (IBAction)actionSkip:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
