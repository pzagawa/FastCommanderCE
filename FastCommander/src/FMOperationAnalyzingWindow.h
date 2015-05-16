//
//  FMOperationAnalyzingWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationAnalyzingWindow : FMOperationWindow

@property (weak) IBOutlet NSProgressIndicator *operationProgress;

- (IBAction)actionCancel:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
