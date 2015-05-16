//
//  FMOperationDeleteWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 17.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationDeleteWindow : FMOperationWindow

@property (weak) IBOutlet NSTextField *textTotalFilesInfo;
@property (weak) IBOutlet NSTextField *textTotalSizeInfo;
@property (weak) IBOutlet NSProgressIndicator *operationProgress;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
