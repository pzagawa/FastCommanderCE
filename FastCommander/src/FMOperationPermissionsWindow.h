//
//  FMOperationPermissionsWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 21.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationPermissionsWindow : FMOperationWindow

@property (weak) IBOutlet NSTextField *textTotalFilesInfo;
@property (weak) IBOutlet NSTextField *textTotalDirectoriesInfo;
@property (weak) IBOutlet NSProgressIndicator *operationProgress;

@property (weak) IBOutlet NSButton *checkUserR;
@property (weak) IBOutlet NSButton *checkUserW;
@property (weak) IBOutlet NSButton *checkUserX;

@property (weak) IBOutlet NSButton *checkGroupR;
@property (weak) IBOutlet NSButton *checkGroupW;
@property (weak) IBOutlet NSButton *checkGroupX;

@property (weak) IBOutlet NSButton *checkOtherR;
@property (weak) IBOutlet NSButton *checkOtherW;
@property (weak) IBOutlet NSButton *checkOtherX;

@property (weak) IBOutlet NSTextField *textOctal;

@property (weak) IBOutlet NSButton *checkProcessSubdirectories;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;

- (IBAction)actionChangeBit:(id)sender;
- (IBAction)actionChangeOctalText:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
