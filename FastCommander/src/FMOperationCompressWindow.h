//
//  FMOperationCompressWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationWindow.h"

@interface FMOperationCompressWindow : FMOperationWindow

@property (weak) IBOutlet NSTextField *textTotalFilesInfo;
@property (weak) IBOutlet NSTextField *textTotalSizeInfo;
@property (weak) IBOutlet NSProgressIndicator *operationProgress;

@property (weak) IBOutlet NSTextField *editFileName;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
